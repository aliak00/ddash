module algorithm.droprightwhile;

import std.range: isBidirectionalRange;

auto dropRightWhile(alias pred, Range)(Range range) if (isBidirectionalRange!Range) {
    import std.functional: unaryFun;
    import std.traits: isArray;

    static if (isArray!Range)
    {
        import std.range: empty, back, popBack;
    }

    while (!range.empty && unaryFun!pred(range.back)) range.popBack;
    return range;
}

unittest {
    import std.array;
    assert([1, 2, 3, 4].dropRightWhile!(a => a > 2).array == [1, 2]);
}
