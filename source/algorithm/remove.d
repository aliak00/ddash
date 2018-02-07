module algorithm.remove;

///
unittest {
    auto arr = [1, 2, 3, 4];
    auto odds = arr.remove!(a => a % 2 == 0);
    assert(arr.equal([1, 3]));
    assert(odds.equal([1, 3]));
    assert(odds.equal(arr));
}

import common;

/**
    Modified the range by removing elements by predicate

    Params:
        pred = unary predicate that returns true if you want an element removed

    Returns:
        The range you passed in, with elements removed
*/
ref remove(alias pred, Range)(ref Range range) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: stdRemove = remove;
    range = range.stdRemove!pred;
    return range;
}
