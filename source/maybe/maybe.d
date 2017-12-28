module maybe;

import std.stdio: writeln;

struct Maybe(T) {
    alias Some = T;
    alias None = typeof(null);
    T[] bag;
    this(None _) {}
    this(T t) {
        this.bag = [t];
    }
    bool empty() @property {
        return this.bag.length == 0;
    }
    auto front() {
        return this.bag[0];
    }
    void popFront() {
        this.bag = [];
    }
    void opAssign(None _) {
        this.bag = [];
    }
    void opAssign(T t) {
        this.bag = [t];
    }
    bool opEquals(None _) {
        return this.bag.length == 0;
    }
    bool opEquals(T rhs) {
        return this.bag.length == 1 && this.bag[0] == rhs;
    }
    bool opEquals(Maybe!T rhs) {
        return this.bag == rhs.bag;
    }
}

auto maybe(T)(T t) {
    return Maybe!T(t);
}

auto maybe(T)(Maybe!T.None _) {
    return Maybe!T(_);
}

auto maybe(T)() {
    return Maybe!T(null);
}

auto isNull(T)(Maybe!T maybe) {
    return maybe == null;
}

import std.traits;
import std.range;

template isMaybe(T) {
    const isMaybe = __traits(compiles, (T.Some a, T.None b) {});
}

auto fmap(Range)(Range range) if (isInputRange!Range && isMaybe!(ElementType!Range)) {
    import std.algorithm: filter, map;
    return range.filter!(a => a != null).map!(a => a.front);
}

auto fmap(Range)(Range range) if (isInputRange!Range && !isMaybe!(ElementType!Range)) {
    import std.algorithm: map;
    return map!(a => a);
}

unittest {
    auto arr = [
        maybe!int,
        maybe(3), 
        maybe!int, 
        maybe(7),
    ];
    arr.fmap.writeln;
}

unittest {
    Maybe!int n = null;
    assert(n == null);
    n = 9;
    assert(n == 9);
    assert(n != null);
}

unittest {
    import std.functional: not;
    import std.algorithm: filter;
    import std.range: array;
    auto arr = [
        maybe!int,
        maybe(3), 
        maybe!int, 
        maybe(7),
    ];
    assert(arr.filter!(not!isNull).array == [maybe(3), maybe(7)]);
}