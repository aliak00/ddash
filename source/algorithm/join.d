/// Converts all elements in range into a string separated by separator.
module algorithm.join;

///
unittest {
    assert([1, 2, 3].join(',') == "1,2,3");
    assert([1, 2, 3].join == "123");
    assert([1, 2, 3].join("-") == "1-2-3");
}

import common;

/**
    Converts all elements in range into a string separated by separator.

    Params:
        range = an input range
        sep = string/char to be used as seperator, default is empty.

    Returns:
        New string

    Since:
        0.1.0
*/
string join(Range, S)(Range range, S sep) if (from!"std.traits".isSomeChar!(from!"std.range".ElementType!S)) {
    import std.algorithm: joiner, map;
    import std.conv: to;
    import std.array;
    return range
        .map!(to!string)
        .joiner(sep)
        .to!string;
}

/// ditto
string join(Range, S)(Range range, S sep) if (from!"std.traits".isSomeChar!S) {
    return range.join([sep]);
}

/// Ditto
string join(Range)(Range range) {
    return range.join("");
}
