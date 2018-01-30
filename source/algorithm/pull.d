/**
    Removes elements from a range
*/
module algorithm.pull;

///
unittest {
    int[] arr = [1, 2, 3, 4, 5];
    arr.pull(1, [2, 5]);
    assert(arr == [3, 4]);

    import std.math: ceil;
    double[] farr = [2.1, 1.2];
    assert(farr.pull!ceil([2.3, 3.4]) == [1.2]);

    farr = [2.1, 1.2];
    assert(farr.pull!((a, b) => ceil(a) == ceil(b))([2.3, 3.4]) == [1.2]);

    // What is this supposed to mean...
    //arr = [1, 2, 3, 4, 5];
    //arr.pull!"a % 2 == 0"(3, 5).writeln;
}

import common;

/**
    Removes elements from a range.

    Params:
        range = a mutable range
        values = variables args of ranges and values to pull out

    Returns:
        Modified range
*/
ref pull(alias pred = null, Range, Values...)(return ref Range range, Values values) {
    import std.algorithm: canFind, remove;
    import algorithm: concat;
    import internal: equalityComparator;
    alias equal = (a, b) => equalityComparator!pred(a, b);
    range = range.remove!(a => values.concat.canFind!equal(a));
    return range;
}
