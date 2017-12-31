module optional;

struct None {}
auto none = None();

struct Optional(T) {
    import std.traits: isPointer, PointerTarget;
    T[] bag;
    this(U : T)(U u) {
        this.bag = [u];
    }
    bool empty() @property {
        return this.bag.length == 0;
    }
    ref front() {
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
    bool opEquals(U : T)(Optional!U rhs) {
        return this.bag == rhs.bag;
    }
    T* unwrap() {
        return this.empty ? null : &this.bag[0];
    }
    string toString() {
        import std.conv: to;
        if (this.bag.length == 0) {
            return "no!" ~ T.stringof;
        }
        return "some!" ~ T.stringof ~ "(" ~ front.to!string ~ ")";
    }

    bool opEquals(U : T)(U rhs) {
        return !empty && front == rhs;
    }

    auto opUnary(string op)() if (op == "*" && isPointer!T) {
        alias P = PointerTarget!T;
        return empty ? no!P: some!P(*front);
    }

    auto opDispatch(string fn, Args...)(Args args) if (!isOptional!T) {
        static if (Args.length) {
            alias C = () => mixin("front." ~ fn)(args);
        } else {
            alias C = () => mixin("front." ~ fn);
        }
        alias R = typeof(C());
        static if (isPointer!T) {
            return this.empty || front is null ? no!R : some(C());
        } else  {
            return this.empty ? no!R : some(C());
        }
    }
}

auto optional(T)(T t) {
    return Optional!T(t);
}

auto optional(T)() {
    return Optional!T();
}

auto some(T)(T t) {
    return Optional!T(t);
}

auto no(T)() {
    return Optional!T();
}

unittest {
    auto a = optional!int;
    assert(a == none);
    a = 9;
    assert(a == some(9));
    assert(a != none);
}

unittest {
    auto a = optional!(int*);
    assert(*a != 9);
    a = new int(9);
    assert(*a == 9);
    assert(a != none);
    a = null;
    assert(a != none);
}

unittest {
    struct Object {
        int f() {
            return 7;
        }
    }
    auto a = some(Object());
    auto b = no!Object;

    assert(a.f() == some(7));
    assert(b.f() == no!int);
}


unittest {
    struct B {
        int f() {
            return 8;
        }
        int m = 3;
    }
    struct A {
        B *b_;
        B* b() {
            return b_;
        }
    }

    auto a = some(new A(new B));
    auto b = some(new A);

    assert(a.b.f == some(8));
    assert(a.b.m == some(3));

    assert(b.b.f == no!int);
    assert(b.b.m == no!int);
}

unittest {
    static assert(!__traits(compiles, some(some(3)).max));
}

unittest {
    import std.algorithm: filter;
    import std.range: array;
    auto arr = [
        no!int,
        some(3),
        no!int,
        some(7),
    ];
    assert(arr.filter!(a => a != none).array == [some(3), some(7)]);
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

unittest {
    assert(no!int.toString == "no!int");
    assert(some(3).toString == "some!int(3)");
}