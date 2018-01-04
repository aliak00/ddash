module algorithm.difference;

import std.range: isInputRange;

struct Difference(alias pred = "a", Range) if (isInputRange!Range) {
    import std.range: ElementType;
    import std.traits: isArray;
    import std.functional: unaryFun;

    alias Element = ElementType!Range;
    alias transform = unaryFun!pred;

    static if (isArray!Range) {
        import std.array;
    }

    Range source;
    bool[Element] cache;

    void skipElementsInCache() {
        while (!this.source.empty && transform(this.source.front) in this.cache) {
            this.source.popFront;
        }
    }

    import traits: isKeySubstitutableWith;

    this(Values)(Range range, Values values) if (isKeySubstitutableWith!(Element, ElementType!(Values))) {
        this.source = range;
        foreach (v; values) {
            this.cache[transform(v)] = true;
        }
        this.skipElementsInCache;
    }

    bool empty() {
        return this.source.empty;
    }
    auto front() {
        return this.source.front;
    }
    void popFront() {
        this.source.popFront;
        this.skipElementsInCache;
    }
}

auto difference(alias pred = "a", Range, Values...)(Range range, Values values) if (isInputRange!Range) {
    import std.range: ElementType;
    import algorithm: concat;
    import traits: isKeySubstitutableWith;
    static if (Values.length)
    {
        static if (isInputRange!(Values[0]))
        {
            auto head = values[0];
        }
        else static if (isKeySubstitutableWith!(ElementType!Range, Values[0]))
        {
            import std.range: only;
            auto head = only(values[0]);
        }
        else
        {
            static assert(0, "Cannot find difference between type " ~ Values[0].stringof ~ " and range of " ~ ElementType!Range.stringof);
        }
        return Difference!(pred, Range)(range, head.concat(values[1..$]));
    }
    else
    {
        return range;
    }
}

unittest {
    import std.array;
    assert([1, 2, 3].difference([1, 2]).array == [3]);
    assert([1, 2, 3].difference([1], 2).array == [3]);
    assert([1, 2, 3].difference([1], [3]).array == [2]);
    assert([1, 2, 3].difference(3).array == [1, 2]);
}

unittest {
    import std.array;

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
    import std.array;
    assert([2.1, 1.2].difference!ceil([2.3, 3.4]).array == [1.2]);
}
