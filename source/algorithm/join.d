module algorithm.join;

import common;

string join(Range, S)(Range range, S sep) if (from!"std.traits".isSomeChar!(from!"std.range".ElementType!S)) {
    import std.algorithm: joiner, map;
    import std.conv: to;
    import std.array;
    return range
        .map!(to!string)
        .joiner(sep)
        .to!string;
}

string join(Range, S)(Range range, S sep = ',') if (from!"std.traits".isSomeChar!S) {
    return range.join([sep]);
}

unittest {
    assert([1, 2, 3].join(',') == "1,2,3");
    assert([1, 2, 3].join == "1,2,3");
    assert([1, 2, 3].join("-") == "1-2-3");
}