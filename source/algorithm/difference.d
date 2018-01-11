module algorithm.difference;

import std.range: isInputRange;

struct Difference(alias pred = "a", R1, R2) if (isInputRange!R1 && isInputRange!R2) {
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
            bool poppedOne = true;
            while (!this.r2.empty && poppedOne) {
                poppedOne = false;
                while (!this.r1.empty && equal(this.r1.front, this.r2.front)) {
                    this.r1.popFront;
                    poppedOne = true;
                }
                if (poppedOne) {
                    this.r2.popFront;
                }
            }
        }
        else static if (r2Sorted)
        {
            // TODO: This path is not tested in any of the unittests
            while (!this.r1.empty && this.r2.contains!equal(this.r1.front)) {
                this.r1.popFront;
            }
        }
        else
        {
            import std.algorithm: canFind;
            import std.range: empty, front, popFront;
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

auto difference(alias pred = "a", Range, Values...)(Range range, Values values) if (isInputRange!Range) {
    static if (Values.length)
    {
        import std.range: ElementType, SortedRange;
        import std.algorithm: sort;
        import range.traits: isSorted;
        import algorithm: concat;
        auto other = concat(values);
        static assert (is(ElementType!(typeof(other)) : ElementType!Range));

        enum r1Sorted = isSorted!(typeof(range));
        enum r2Sorted = isSorted!(typeof(other));
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

        return Difference!(pred, typeof(r1), typeof(r2))(r1, r2);
    }
    else
    {
        return range;
    }
}

version (unittest) {
    import std.array;
}

unittest {
    // assert([1, 2, 3].difference([0, 1, 2]).array == [3]);
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
