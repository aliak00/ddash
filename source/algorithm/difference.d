module algorithm.difference;

import std.range: isInputRange;


static struct Difference(Range) {
    import std.range: ElementType;
    import std.array;
    Range source;
    bool[ElementType!Range] cache;

    void moveUntilNotInCache() {
        while (!source.empty && source.front in cache) {
            source.popFront;
        }
    }

    this(Values)(Range range, Values values) {
        this.source = range;
        foreach (v; values) {
            this.cache[v] = true;
        }
        moveUntilNotInCache;
    }

    bool empty() {
        return this.source.empty;
    }
    auto front() {
        return this.source.front;
    }
    void popFront() {
        source.popFront;
        moveUntilNotInCache;
    }
}

auto difference(Range, Values...)(Range range, Values values) {
    import std.range: ElementType;
    import algorithm.concat;
    static if (Values.length) {
        static if (isInputRange!(Values[0])) {
            auto head = values[0];
        } else static if (is(Values[0] : ElementType!Range)) {
            import std.range: only;
            auto head = only(values[0]);
        } else {
            static assert(0, "Cannot find difference between type " ~ Values[0].stringof ~ " and range of " ~ ElementType!Range.stringof);
        }
        return Difference!Range(range, head.concat(values[1..$]));
    } else {
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
