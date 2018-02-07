/**
    Returns the sorting predicate that was used to sort a range
*/
module range.sortingpredicate;

///
unittest {
    import std.algorithm: sort;
    assert([3, 1].sort!"a < b".sortingPredicate(1, 2) == true);
    assert([3, 1].sort!"a > b".sortingPredicate(1, 2) == false);
    assert([3, 1].sort!((a, b) => a < b).sortingPredicate(1, 2) == true);
    assert([3, 1].sort!((a, b) => a > b).sortingPredicate(1, 2) == false);
    assert(!is(typeof([1].sortingPredicate)));
}

import common;

/**
    Given a `SortedRange`, `sortingPredicate(a, b)` will call in to the predicate
    that was used to create the `SortedRange`
*/
auto sortingPredicate(Range, T, U)(Range range, auto ref T a, auto ref U b)
if (from!"std.range".isInputRange!Range && from!"utils.traits".isSortedRange!Range)
{
    import std.range: SortedRange;
    static if (is(Range : SortedRange!P, P...))
    {
        import std.functional: binaryFun;
        return binaryFun!(P[1])(a, b);
    }
    else
    {
        static assert(0, "Could not decompose sorting predicate for " ~ Range.stringof);
    }
}
