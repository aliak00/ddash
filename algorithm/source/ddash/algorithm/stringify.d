/// Converts all elements in range into a string separated by separator.
module ddash.algorithm.stringify;

///
@("Modue example")
unittest {
    assert([1, 2, 3].stringifySeparatedBy(',') == "1,2,3");
    assert([1, 2, 3].stringify == "123");
    assert([1, 2, 3].stringifySeparatedBy("-") == "1-2-3");
}

import ddash.common;

/**
    Converts all elements in range into a string separated by separator.

    Params:
        range = an input range
        sep = string/char to be used as seperator, default is empty.

    Returns:
        New string

    Since:
        0.0.1
*/
string stringifySeparatedBy(Range, S)(Range range, S sep) if (from.std.traits.isSomeString!S) {
    import std.algorithm: joiner, map;
    import std.conv: to;
    return range
        .map!(to!string)
        .joiner(sep)
        .to!string;
}

/// Ditto
string stringifySeparatedBy(Range, S)(Range range, S sep) if (from.std.traits.isSomeChar!S) {
    import std.conv: to;
    return range.stringifySeparatedBy(sep.to!string);
}

/**
    Converts a list of values in to a string

    Params:
        values = combinable sequence of values

    Returns:
        New string

    Since:
        0.0.1
*/
string stringify(Values...)(Values values) {
    import ddash.algorithm: concat;
    return concat(values).stringifySeparatedBy("");
}
