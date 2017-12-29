module algorithm.countuntil;

import std.algorithm: stdCountUntil = countUntil;
import optional;

auto countUntil(alias pred = "a == b", R, Rs...)(R haystack, Rs needles) {
    
    auto result = stdCountUntil!(pred, R, Rs)(haystack, needles);
    return result == -1 ? none!ptrdiff_t : some!ptrdiff_t(result);
}

unittest {
    assert([1, 2].countUntil(2) == some!long(1));
    assert([1, 2].countUntil(0) == none!long);
}
