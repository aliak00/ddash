/**
    Implementations of `std.algorithm.countUntil` from Phobos with `optional` behavior
*/
module phobos.countuntil;

///
unittest {
    import optional: none, some;
    assert([1, 2].countUntil(2) == some(1));
    assert([1, 2].countUntil(0) == none);
}

/**
    Same as Phobos version, but returns an `optional`
*/
auto countUntil(alias pred = "a == b", Range, Values...)(Range haystack, Values needles) {
    import optional: no, some;
    import std.algorithm: stdCountUntil = countUntil;
    auto result = stdCountUntil!(pred, Range, Values)(haystack, needles);
    return result == -1 ? no!size_t : some(cast(size_t)result);
}
