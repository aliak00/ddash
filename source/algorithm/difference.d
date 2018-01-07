module algorithm.difference;

import std.range: isInputRange;

struct Difference(alias pred = "a", R1, R2) if (isInputRange!R1 && isInputRange!R2) {
    import std.range: ElementType;
    import std.traits: isArray;
    import std.functional: unaryFun, binaryFun;

    alias Element = ElementType!R2;

    enum isUnary = is(typeof(unaryFun!pred(Element.init)));
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

    static if (isArray!R1 || isArray!R2) {
        import std.array;
    }

    R1 r1;
    R2 r2;

    bool frontsEqual() {
        return !this.r1.empty && !this.r2.empty && compare(transform(this.r1.front), transform(this.r2.front));
    }

    void moveToNextElement() {
        import range: popIfFront;
        bool poppedOne = true;
        while (!r2.empty && poppedOne) {
            poppedOne = false;
            while (this.frontsEqual) {
                this.r1.popFront;
                poppedOne = true;
            }
            if (poppedOne) {
                this.r2.popFront;
            }
        }
    }

    this(R1 r1, R2 r2) {
        this.r1 = r1;
        this.r2 = r2;
        moveToNextElement;
    }

    bool empty() @property {
        return this.r1.empty;
    }
    auto front() @property {
        return this.r1.front;
    }
    void popFront() {
        this.r1.popFront;
        moveToNextElement;
    }
}

auto difference(alias pred = "a", Range, Values...)(Range range, Values values) if (isInputRange!Range) {
    import std.range: ElementType;
    import std.algorithm: sort;
    import algorithm: concat;
    static if (Values.length)
    {
        static if (isInputRange!(Values[0]) && is(ElementType!(Values[0]) : ElementType!Range))
        {
            auto head = values[0];
        }
        else static if (is(Values[0] : ElementType!Range))
        {
            auto head = [values[0]];
        }
        else
        {
            static assert(0, "Cannot find difference between type " ~ Values[0].stringof ~ " and range of " ~ ElementType!Range.stringof);
        }
        import std.traits, std.range;

        auto r1 = range.sort;
        auto r2 = head.concat(values[1..$]).sort;
        alias R1 = typeof(r1);
        alias R2 = typeof(r2);
        return Difference!(pred, R1, R2)(r1, r2);
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
        bool opCmp(A rhs) {
            return value < rhs.value;
        }
    }
    assert([A(1), A(2), A(3)].difference!((a, b) => a.value == b.value)([A(2), A(3)]).array == [A(1)]);
}
