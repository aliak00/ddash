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
    ref PointerTarget!T opUnary(string op)() if (op == "*" && isPointer!T) {
        return *(this.bag[0]);
    }
    auto opDispatch(string fn, Args...)(Args args) {
        alias Fn = () => mixin("bag[0]." ~ fn)(args);
        alias R = typeof(Fn());
        static if (isPointer!T) {
            return this.empty || this.bag[0] is null ? Optional!R() : Optional!R(Fn());
        } else  {
            return this.empty ? Optional!R() : Optional!R(Fn());
        }
    }
}

auto optional(T)(T t) {
    return Optional!T(t);
}

auto optional(T)() {
    return Optional!T();
}

unittest {
    Optional!int a;
    assert(a == none);
    a = 9;
    assert(a == optional(9));
    assert(a != none);
}

unittest {
    Optional!(int*) a;
    assert(a == none);
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
    auto a = optional(Object());
    auto b = optional!Object;

    assert(a.f() == optional(7));
    assert(b.f() == optional!int);
}

unittest {
    struct B {
        int f() {
            return 8;
        }
    }
    struct A {
        B *b;
        B* f() {
            return b;
        }
    }

    assert(optional(new A(new B)).f.f == optional(8));
    assert(optional(new A).f.f == optional!int);
}

auto some(T)(T t) {
    return Optional!T(t);
}

auto no(T)() {
    return optional!T();
}

auto isSome(T)(Optional!T maybe) {
    return maybe != none;
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
    assert(arr.filter!isSome.array == [some(3), some(7)]);
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
