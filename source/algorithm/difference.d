/**
    Creates a range of values not included in the other given ranges.
*/
module algorithm.difference;

///
unittest {
    assert([1, 2, 3].difference([1], 3).equal([2]));

    import std.math: ceil;
    assert([2.1, 1.2].difference!ceil([2.3, 3.4]).equal([1.2]));
    assert([2.1, 1.2].difference!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).equal([1.2]));

    struct A {
        int value;
    }

    assert([A(1), A(2), A(3)].difference!((a, b) => a.value == b.value)([A(2), A(3)]).equal([A(1)]));
}

import common;

struct Difference(string member, alias pred, R1, R2) if (from!"std.range".isInputRange!R1 && from!"std.range".isInputRange!R2) {
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
            import algorithm: equal;
            alias eq = (a, b) => equalBy!(member, pred)(a, b);
            while (!this.r1.empty && this.r2.canFind!eq(this.r1.front)) {
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
    Creates a range of values not included in the other given ranges.

    The `pred` defaults to null. If a unary predicate is passed in, then a transformation
    will be appled to each element before comparing. If a binary predicate is passed in, it
    will determine equality of elements.

    If `pred` is null or unary, and the range is sortable or is sorted, an optimized linear
    algorithm will be used instead using the range's
    $(DDOX_NAMED_REF range.sortingpredicate, `sorting predicate`)

    Params:
        pred = unary transformation or binary comparator
        range = the range to inspect
        values = ranges or single values to exclude

    Returns:
        New array of filtered results. If `Rs` is empty, then `range` is returned
*/
auto difference(alias pred = null, Range, Rs...)(Range range, Rs values)
if (from!"std.range".isInputRange!Range
    && (from!"bolts.traits".isNullType!pred
        || from!"bolts.traits".isUnaryOver!(pred, from!"std.range".ElementType!Range)
        || from!"bolts.traits".isBinaryOver!(pred, from!"std.range".ElementType!Range)))
{
    return differenceBase!("", pred)(range, values);
}

unittest {
    assert([1, 2, 3].difference([0, 1, 2]).equal([3]));
    assert([1, 2, 3].difference([1, 2]).equal([3]));
    assert([1, 2, 3].difference([1], 2).equal([3]));
    assert([1, 2, 3].difference([1], [3]).equal([2]));
    assert([1, 2, 3].difference(3).equal([1, 2]));
}

unittest {
    // Implicitly convertible elements ok
    assert([1.0, 2.0].difference(2).equal([1.0]));

    // Implicitly convertible ranges ok
    assert([1.0, 2.0].difference([2]).equal([1.0]));

    // Non implicily convertible elements not ok
    static assert(!__traits(compiles, [1].difference(1.0)));

    // Non implicily convertible range not ok
    static assert(!__traits(compiles, [1].difference([1.0])));
}

unittest {
    import std.math: ceil;
    assert([2.1, 1.2].difference!ceil([2.3, 3.4]).equal([1.2]));
    assert([2.1, 1.2].difference!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]).equal([1.2]));
}

/**
    Same as `difference` except you can make it operatete on a publicly accessible member of ElementType!Range

    Params:
        member = which member in `ElementType!Range` to find difference over
        pred = unary transformation or binary comparator
        range = the range to inspect
        values = ranges or single values to exclude

    SeeAlso:
        `difference`
*/
auto differenceBy(string member, alias pred = null, Range, Rs...)(Range range, Rs values)
if (from!"std.range".isInputRange!Range
    && (from!"bolts.traits".isNullType!pred
        || from!"bolts.traits".isUnaryOver!(pred, from!"std.range".ElementType!Range)
        || from!"bolts.traits".isBinaryOver!(pred, from!"std.range".ElementType!Range)))
{
    return differenceBase!(member, pred)(range, values);
}

///
unittest {
    struct A {
        int value;
    }
    // with normal difference
    assert([A(1), A(2), A(3)].difference!((a, b) => a.value == b.value)([A(2), A(3)]).equal([A(1)]));

    // by using the By() version
    assert([A(1), A(2), A(3)].differenceBy!"value"([A(2), A(3)]).equal([A(1)]));
}

auto differenceBase(string member, alias pred, Range, Values...)(Range range, Values values)
if (from!"std.range".isInputRange!Range
    && from!"bolts.traits".areCombinable!(Range, Values)
    && (from!"bolts.traits".isNullType!pred
        || from!"bolts.traits".isUnaryOver!(pred, from!"std.range".ElementType!Range)
        || from!"bolts.traits".isBinaryOver!(pred, from!"std.range".ElementType!Range)))
{
    static if (!Values.length)
    {
        return range;
    }
    else
    {
        import std.range: ElementType;
        import algorithm: concat;
        import bolts.traits: isBinaryOver;

        auto combinedValues = values.concat;
        static assert(
            is(ElementType!(typeof(combinedValues)) : ElementType!Range),
            "Cannot get difference between supplied range of element type `"
                ~ ElementType!Range.stringof
                ~ "` and values of element type `"
            ~ ElementType!(typeof(combinedValues)).stringof ~ "`"
        );

        static if (!isBinaryOver!(pred, ElementType!Range) && member.length == 0)
        {
            import std.algorithm: sort;
            static if (is(typeof(range.sort)))
                auto r1 = range.sort;
            else
                auto r1 = range;

            static if (is(typeof(combinedValues.sort)))
                auto r2 = combinedValues.sort;
            else
                auto r2 = combinedValues;
        }
        else
        {
            auto r1 = range;
            auto r2 = combinedValues;
        }

        return Difference!(member, pred, typeof(r1), typeof(r2))(r1, r2);
    }
}
