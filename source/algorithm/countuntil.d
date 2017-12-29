module algorithm.countuntil;

import std.algorithm: stdCountUntil = countUntil;
import optional;

auto countUntil(alias pred = "a == b", R, Rs...)(R haystack, Rs needles) {
    auto result = stdCountUntil!(pred, R, Rs)(haystack, needles);
    return result == -1 ? no!long : some(result);
}

unittest {
    assert([1, 2].countUntil(2) == some(1));
    assert([1, 2].countUntil(0) == no!long);
}
