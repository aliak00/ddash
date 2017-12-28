module maybe;

version(unittest) {
    import std.stdio: writeln;
    import std.array;
}

template from(string moduleName) {
    mixin("import from = " ~ moduleName ~ ";");
}

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
    auto opDispatch(string fn, Args...)(Args args) {
        alias Fn = () => mixin("front." ~ fn)(args);
        alias R = typeof(Fn());
        return empty? maybe!R : maybe(Fn());
    }
}

unittest {
    Maybe!int n = null;
    assert(n == null);
    n = 9;
    assert(n == 9);
    assert(n != null);
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

template isMaybe(T) {
    static if(is(T U == Maybe!U)) {
        enum isMaybe = true;
    } else {
        enum isMaybe = false;
    }
}

unittest {
    assert(isMaybe!(Maybe!int) == true);
    assert(isMaybe!int == false);
    assert(isMaybe!(int[]) == false);
}

auto flatMap(alias fun, Range)(Range r) if (from!"std.range".isInputRange!Range) {
    import std.algorithm: map;
    import std.range: ElementType;
    static if (isMaybe!(ElementType!Range)) {
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
        maybe!int,
        maybe(3),
        maybe!int,
        maybe(7),
    ];
    assert(arr.flatMap!(a => a).array == [3, 7]);
}

unittest {
    struct Some {
        int f() {
            return 7;
        }
    }
    auto a = maybe(Some());
    auto b = maybe!Some;

    assert(a.f() == maybe(7));
    assert(b.f() == maybe!int);
}