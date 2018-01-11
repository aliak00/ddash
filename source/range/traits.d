module range.traits;

import common: from;

bool isSorted(Range)() if (from!"std.range".isInputRange!Range) {
    import std.range: SortedRange;
    return is(Range : SortedRange!T, T...);
}

unittest {
    import std.algorithm: sort;
    import std.range: assumeSorted;
    static assert(isSorted!(typeof([0, 1, 2])) == false);
    static assert(isSorted!(typeof([0, 1, 2].sort)) == true);
    static assert(isSorted!(typeof([0, 1, 2].assumeSorted)) == true);
}
