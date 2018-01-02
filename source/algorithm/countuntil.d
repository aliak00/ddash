module algorithm.countuntil;

import optional: no, some;

auto countUntil(alias pred = "a == b", Range, Values...)(Range haystack, Values needles) {
    import std.algorithm: stdCountUntil = countUntil;
    auto result = stdCountUntil!(pred, Range, Values)(haystack, needles);
    return result == -1 ? no!long : some(result);
}

unittest {
    import optional: none;
    assert([1, 2].countUntil(2) == some(1));
    assert([1, 2].countUntil(0) == none);
}
