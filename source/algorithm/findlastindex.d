module algorithm.findlastindex;

import std.range: isBidirectionalRange;

auto findLastIndex(alias pred = "a == b", Range, Values...)(Range range, Values values) if (isBidirectionalRange!Range) {
    import std.range: retro, walkLength;
    import algorithm: findIndex;
    import range: withFront;
    return range
        .retro
        .findIndex!pred(values)
        .withFront!(a => range.walkLength - a - 1);
}

unittest {
    import optional: some, none;
    assert([1, 2, 2, 1].findLastIndex(2) == some(2));
    assert([1, 2, 2, 1].findLastIndex(1) == some(3));
    assert([1, 2, 2, 1].findLastIndex(3) == none);
}
