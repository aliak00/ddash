/// Converts all elements in range into a string separated by separator.
module algorithm.stringify;

///
unittest {
    assert([1, 2, 3].stringify(',') == "1,2,3");
    assert([1, 2, 3].stringify == "123");
    assert([1, 2, 3].stringify("-") == "1-2-3");
}

import common;

/**
    Converts all elements in range into a string separated by separator.

    Params:
        range = an input range
        sep = string/char to be used as seperator, default is empty.

    Returns:
        New string
*/
string stringify(Range, S)(Range range, S sep = "") if (from!"std.traits".isSomeString!S) {
    import std.algorithm: joiner, map;
    import std.conv: to;
    import std.array;
    return range
        .map!(to!string)
        .joiner(sep)
        .to!string;
}

/// ditto
string stringify(Range, S)(Range range, S sep) if (from!"std.traits".isSomeChar!S) {
    import std.conv: to;
    return range.stringify(sep.to!string);
}
