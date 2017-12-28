module optional;

version(unittest) {
    import std.stdio: writeln;
    import std.array;
}

template from(string moduleName) {
    mixin("import from = " ~ moduleName ~ ";");
}

struct Optional(T) {
    alias Null = typeof(null);
    T[] bag;
    this(Null _) {}
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
    void opAssign(Null _) {
        this.bag = [];
    }
    void opAssign(T t) {
        this.bag = [t];
    }
    bool opEquals(Null _) {
        return this.bag.length == 0;
    }
    bool opEquals(T rhs) {
        return this.bag.length == 1 && this.bag[0] == rhs;
    }
    bool opEquals(Optional!T rhs) {
        return this.bag == rhs.bag;
    }
    auto opDispatch(string fn, Args...)(Args args) {
        alias Fn = () => mixin("front." ~ fn)(args);
        alias R = typeof(Fn());
        return empty? Optional!R() : Optional!R(Fn());
    }
}

unittest {
    Optional!int n = null;
    assert(n == null);
    n = 9;
    assert(n == 9);
    assert(n != null);
}

auto optional(T)(T t) {
    return Optional!T(t);
}

auto optional(T)(Optional!T.Null _) {
    return Optional!T(_);
}

auto optional(T)() {
    return Optional!T(null);
}

auto some(T)(T t) {
    return Optional!T(t);
}

auto none(T)() {
    return Optional!T();
}

auto isNull(T)(Optional!T maybe) {
    return maybe == null;
}

unittest {
    import std.functional: not;
    import std.algorithm: filter;
    import std.range: array;
    auto arr = [
        optional!int,
        optional(3), 
        optional!int, 
        optional(7),
    ];
    assert(arr.filter!(not!isNull).array == [some(3), some(7)]);
}

template isOptional(T) {
    static if(is(T U == Optional!U)) {
        enum isOptional = true;
    } else {
        enum isOptional = false;
    }
}

unittest {
    assert(isOptional!(Optional!int) == true);
    assert(isOptional!int == false);
    assert(isOptional!(int[]) == false);
}

auto flatMap(alias fun, Range)(Range r) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: map;
    import std.range: ElementType;
    static if (isOptional!(ElementType!Range)) {
        import std.algorithm: filter;
        return r.filter!(a => a != null).map!(a => a.front).map!(fun);
    } else if (__traits(compiles, { ElementType!Range t = null; })) {
        import std.algorithm: filter;
        return r.filter!(a => a != null).map!(fun);
    } else {
        return r.map!(fun);
    }
}

unittest {
    auto arr = [
        optional!int,
        optional(3),
        optional!int,
        optional(7),
    ];
    assert(arr.flatMap!(a => a).array == [3, 7]);
}

unittest {
    struct Object {
        int f() {
            return 7;
        }
    }
    auto a = some(Object());
    auto b = none!Object;

    assert(a.f() == some(7));
    assert(b.f() == none!int);
}