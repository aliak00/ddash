module utils.mixins;

import common;

mixin template PropogateInfiniteRange(Range, alias emptyPred) if (from!"std.range".isInputRange!Range) {
    import std.range: isInfinite;
    static if (isInfinite!R)
    {
        enum bool empty = false;
    }
    else
    {
        @property bool empty()
        {
            return emptyPred(this);
        }
    }
}

unittest {
    import std.range: sequence, isInfinite;
    import std.array;
    struct A(R) {
        R src;
        void popFront() { src.popFront(); }
        auto front() { return src.front; }
        mixin PropogateInfiniteRange!(R, (self) => self.src.empty);
    }
    auto arr = [1, 2, 3];
    auto ints = sequence!((a, n) => n);
    auto a = A!(typeof(arr))(arr);
    auto b = A!(typeof(ints))(ints);
    static assert(isInfinite!(typeof(a)) == false);
    static assert(isInfinite!(typeof(b)) == true);
}
