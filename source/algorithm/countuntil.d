module algorithm.countuntil;

import optional: no, some;

auto countUntil(alias pred = "a == b", R, Rs...)(R haystack, Rs needles) {
    import std.algorithm: stdCountUntil = countUntil;
    auto result = stdCountUntil!(pred, R, Rs)(haystack, needles);
    return result == -1 ? no!long : some(result);
}

unittest {
    import optional: none;
    assert([1, 2].countUntil(2) == some(1));
    assert([1, 2].countUntil(0) == none);
}
