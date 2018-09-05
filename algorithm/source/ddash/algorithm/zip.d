/**
    Zips up ranges up together
*/
module ddash.algorithm.zip;

///
unittest {
    auto r1 = [[1, 2, 3], [4, 5, 6]];
    assert(r1.zipEach.equal([[1, 4], [2, 5], [3, 6]]));
    auto r2 = [[1, 3], [4, 5, 6]];
    assert(r2.zipEach.equal([[1, 4], [3, 5]]));
    auto r3 = [[1, 3], [], [4, 5, 6]];
    assert(r3.zipEach.equal((int[][]).init));
}

import ddash.common;

/**
    Zip a range of ranges together by element.

    I.e. the first elements of each range will be zipped up in to the first "element", the second elements
    of each range will be zipped up to the second element, etc, where eaach element is also a range.

    The number of elemenets in each sub range of the returned range is equal to the input sub range
    that has the lest number of elements.

    Params:
        rangeOfRanges = a range of ranges.

    Returns:
        A range of ranges

    Since:
        0.1.0
*/
auto zipEach(RoR)(RoR rangeOfRanges) if (from!"std.range".isInputRange!(from!"std.range".ElementType!RoR)) {
    static struct Result {
        import std.algorithm: map, any;
        import std.range: drop;
        RoR source;
        size_t position = 0;
        @property empty() const {
            import std.range: empty;
            return source.any!(a => a.drop(position).empty);
        }
        @property auto front() {
            import std.range: front;
            return source.map!(a => a.drop(position).front);
        }
        void popFront() {
            position++;
        }
    }
    return Result(rangeOfRanges);
}

unittest {
    auto r1 = [[1, 4], [2, 5], [3, 6]];
    auto r2 = [[1, 2, 3], [4, 5, 6]].zipEach;
    assert(equal(r1, r2));
}
