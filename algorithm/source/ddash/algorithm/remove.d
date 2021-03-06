/**
    Removes elements from a range
*/
module ddash.algorithm.remove;

///
@("module example")
unittest {
    auto arr = [1, 2, 3, 4];
    arr.remove!(a => a % 2 == 0);
    assert(arr.equal([1, 3]));
}

import ddash.common;

/**
    Modified the range by removing elements by predicate

    Params:
        pred = unary predicate that returns true if you want an element removed
        range = the range to remove element from

    Since:
        0.0.1
*/
void remove(alias pred, Range)(ref Range range) if (from.std.range.isInputRange!Range) {
    import std.algorithm: stdRemove = remove;
    range = range.stdRemove!pred;
}
