module range.sortingpredicate;

import common;

auto sortingPredicate(Range, T)(Range range, auto ref T a, auto ref T b) 
if (from!"std.range".isInputRange!Range && from!"range".isSortedRange!Range)
{
    import std.range: SortedRange;
    static if (is(Range : SortedRange!U, U...))
    {
        import std.functional: binaryFun;
        return binaryFun!(U[1])(a, b);
    }
    else
    {
        static assert(0, "isSorted!Range was true but could not decompose predicate");
    }
}

unittest {
    import std.algorithm: sort;
    assert([3, 1].sort!"a < b".sortingPredicate(1, 2) == true);
    assert([3, 1].sort!"a > b".sortingPredicate(1, 2) == false);
    assert([3, 1].sort!((a, b) => a < b).sortingPredicate(1, 2) == true);
    assert([3, 1].sort!((a, b) => a > b).sortingPredicate(1, 2) == false);
    assert(!is(typeof([1].sortingPredicate)));
}
