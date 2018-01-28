module algorithm.pull;

import common;

ref pull(Range, Values...)(return ref Range range, Values values) {
    import std.algorithm: canFind, moveEmplaceAll;
    import std.array;
    import std.range: popBackN, ElementType;
    import algorithm: concat;
    int numFound = 0;
    auto needles = concat(values);
    auto r = range.save;
    ElementType!Range[] unfoundElements;
    foreach (e; r) {
        if (!needles.canFind(e)) {
            unfoundElements ~= e;
        } else {
            numFound++;
        }
    }
    moveEmplaceAll(unfoundElements, range);
    range.popBackN(numFound);
    return range;
}

unittest {
    int[] arr = [1, 2, 3, 4, 5];
    arr.pull(1, [2, 5]);
    assert(arr == [3, 4]);
}
