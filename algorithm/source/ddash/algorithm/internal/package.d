module ddash.algorithm.internal;

import ddash.common;

auto countUntil(alias pred = "a == b", Range, Values...)(Range haystack, Values needles) {
    import optional: no, some;
    import std.algorithm: stdCountUntil = countUntil;
    auto result = stdCountUntil!(pred, Range, Values)(haystack, needles);
    return result == -1 ? no!size_t : some(cast(size_t)result);
}

unittest {
    import optional: none, some;
    assert([1, 2].countUntil(2) == some(1));
    assert([1, 2].countUntil(0) == none);
    assert([0, 7, 12, 22, 9].countUntil([12, 22]) == some(2));
    assert([1, 2].countUntil!((a, b) => a % 2 == 0)([1, 2]) == some(1));
}
