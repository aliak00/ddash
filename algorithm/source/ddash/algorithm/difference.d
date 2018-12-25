/**
    Creates a range of values not included in the other given ranges.
*/
module ddash.algorithm.difference;

///
@("Module example")
unittest {
    import std.algorithm: map;
    assert([1, 2, 3].difference([1], 3).equal([2]));

    import std.math: ceil;
    assert([2.1, 2.4, 1.2, 2.9].difference!ceil([2.3, 0.1]).equal([1.2]));
    assert([2.1, 2.4, 1.2, 2.9].difference!((a, b) => ceil(a) < ceil(b))([2.3, 3.4]).equal([1.2]));

    struct A {
        int value;
    }

    assert([A(1), A(2), A(3)].difference!((a, b) => a.value < b.value)([A(2), A(3)]).equal([A(1)]));
}

import ddash.common;

private template isRangeOverValidPredicate(alias pred, Range) if (from!"std.range".isInputRange!Range) {
    import bolts.traits: isNullType, isUnaryOver, isBinaryOver;
    import std.range: ElementType;
    enum isRangeOverValidPredicate = isNullType!pred || isUnaryOver!(pred, ElementType!Range) || isBinaryOver!(pred, ElementType!Range);
}

private template isSortednessValid(R1, R2, string byMember, alias pred) {
    import bolts.traits: isNullType;
    import bolts.range: isSortedRange;
    enum isSortednessValid = byMember.length == 0 && isNullType!pred && isSortedRange!R1 && isSortedRange!R2;
}

private struct Difference(string member, alias pred, R1, R2) {
    import bolts.range: CommonTypeOfRanges;

    private R1 r1;
    private R2 r2;

    alias E = CommonTypeOfRanges!(R1, R2);

    private void moveToNextElement() {
        import bolts.traits: isBinaryOver, isNullType;
        import bolts.range: isSortedRange;
        import std.range: empty, front, popFront;

        static if (isSortednessValid!(R1, R2, member, pred)) {
            import bolts.range: sortingPredicate;

            alias cmp = (a, b) => sortingPredicate!R1(a, b);

            while (!r1.empty && !r2.empty) {
                if (cmp(r1.front, r2.front)) {
                    break;
                }
                if (cmp(r2.front, r1.front)) {
                    while (!r2.empty && cmp(r2.front, r1.front)) r2.popFront;
                    continue;
                }
                r1.popFront;
            }
        } else {
            import std.algorithm: canFind;
            import ddash.algorithm: equalBy;

            static if (isBinaryOver!(pred, E)) {
                import ddash.functional: lt;
                alias eq = (a, b) => equalBy!(member, lt!pred)(a, b);
            } else {
                alias eq = (a, b) => equalBy!(member, pred)(a, b);
            }

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

    public bool empty() @property {
        import std.range: empty;
        return this.r1.empty;
    }
    public auto front() @property {
        import std.range: front;
        return this.r1.front;
    }
    public void popFront() {
        import std.range: popFront;
        this.r1.popFront;
        this.moveToNextElement;
    }
}

/**
    Creates a range of values not included in the other given ranges.

    You may pass in a unary or binary predicate. If a unary predicate is passed in, then a
    transformation will be appled to each element before comparing. If a binary predicate is
    passed in, it must be a comparator predicate that returns true if if a < b.

    If `pred` is null or unary, and the range is sortable, a sort is applied followed by an
    optimized linear algorithm. If the range is already sorted and `pred` is null, then the linear algorithm
    is just used with the sorted rang's $(DDOX_NAMED_REF range.sortingpredicate, `sorting predicate`).

    Params:
        pred = unary transformation or binary comparator
        range = the range to inspect
        values = ranges or single values to exclude

    Returns:
        New array of filtered results. If `Rs` is empty, then `range` is returned

    Since:
        0.0.1
*/
auto difference(alias pred = null, Range, Rs...)(Range range, Rs values) if (isRangeOverValidPredicate!(pred, Range)) {
    return differenceBase!("", pred)(range, values);
}

///
@("Different ways of passing parameters")
unittest {
    assert([1, 2, 3].difference([0, 1, 2]).equal([3]));
    assert([1, 2, 3].difference([1, 2]).equal([3]));
    assert([1, 2, 3].difference([1], 2).equal([3]));
    assert([1, 2, 3].difference([1], [3]).equal([2]));
    assert([1, 2, 3].difference(3).equal([1, 2]));
}

///
@("Implicitly convertible elements work")
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

///
@("Elements come out sorted")
unittest {
    import std.math: ceil;
    assert([2.1, 1.2].difference!ceil([2.3, 3.4]).equal([1.2]));
    assert([9, 2, 3, 2, 3, 9].difference([7, 3, 1, 5]).equal([2, 2, 9, 9]));
}

/**
    Same as `difference` except you can make it operatete on a publicly accessible member of ElementType!Range

    Params:
        member = which member in `ElementType!Range` to find difference over
        pred = unary transformation or binary comparator
        range = the range to inspect
        values = ranges or single values to exclude

    See_Also:
        `difference`

    Since:
        0.0.1
*/
auto differenceBy(string member, alias pred = null, Range, Rs...)(Range range, Rs values) if (isRangeOverValidPredicate!(pred, Range)) {
    return differenceBase!(member, pred)(range, values);
}

///
@("Binary predicate and member-wise")
unittest {
    struct A {
        int value;
    }
    // with normal difference
    assert([A(1), A(2), A(3)].difference!((a, b) => a.value < b.value)([A(2), A(3)]).equal([A(1)]));

    // by using the By() version
    assert([A(1), A(2), A(3)].differenceBy!"value"([A(2), A(3)]).equal([A(1)]));
}

private auto differenceBase(string member, alias pred, Range, Values...)(Range range, Values values)
if (isRangeOverValidPredicate!(pred, Range) && from!"bolts.traits".areCombinable!(Range, Values))
{
    static if (!Values.length) {
        return range;
    } else {
        import std.range: ElementType;
        import ddash.algorithm: concat;
        import bolts.traits: isBinaryOver, isUnaryOver;
        import std.meta: Alias;

        auto combinedValues = values.concat;

        alias R1 = Range;
        alias R2 = typeof(combinedValues);
        alias E1 = ElementType!R1;
        alias E2 = ElementType!R2;

        static assert(
            is(E2 : E1),
            "Cannot get difference between supplied range of element type `"
                ~ E1.stringof ~ "` and values of common element type `" ~ E2.stringof ~ "`"
        );

        static if (isSortednessValid!(R1, R2, member, pred)) {
            import bolts.range: sortingPredicate;
            alias sortPred = sortingPredicate!R1;
        } else static if (isUnaryOver!(pred, E1)) {
            alias sortPred = (a, b) => pred(a) < pred(b);
        } else static if (isBinaryOver!(pred, E1, E2)) {
            alias sortPred = pred;
        } else {
            alias sortPred = (a, b) => a < b;
        }

        import ddash.algorithm: maybeSortBy;
        auto r1 = maybeSortBy!(member, sortPred)(range);
        auto r2 = maybeSortBy!(member, sortPred)(combinedValues);

        return Difference!(member, pred, typeof(r1), typeof(r2))(r1, r2);
    }
}

@("gives expected results")
unittest {
    assert([1, 1, 1, 2, 2, 3].difference(2, 3).equal([1, 1, 1]));
    assert([1, 1, 1, 2, 2, 3, 3].difference(2, 3).equal([1, 1, 1]));
    assert([1, 1, 1, 2, 2, 3, 3].difference(3).equal([1, 1, 1, 2, 2]));
    assert([1, 1, 1, 2, 2, 3, 3].difference(2).equal([1, 1, 1, 3, 3]));
    assert([1, 1, 1, 2, 2, 3].difference(1, 2).equal([3]));
    assert([1, 1, 1, 2, 2, 3, 3].difference(1, 2).equal([3, 3]));
    assert([1, 1, 1, 2, 2, 3].difference(-1, 2).equal([1, 1, 1, 3]));
    assert([1, 1, 1, 2, 2, 3].difference(7, 1).equal([2, 2, 3]));
}
