/**
    Home of the Optional type
*/
module optional;

///
unittest {
    auto a = optional!int;
    assert(a == none);
    a = 9;
    assert(a == some(9));

    struct A {
        int f() {
            return 4;
        }
    }

    auto b = some(A());
    assert(b.f == some(4));

    auto c = optional!(A*);
    assert(c.f == none);

    c = new A;
    assert(c.f == some(4));
}


struct None {
    // Space is here else ddox test above includes text "struct Node" in its code block
}

/**
    Represents an empty optional value. This is used for convenience
*/
auto none = None();

/**
    Optional type. Also known as a Maybe type in some languages.

    This can either contain a value or be empty. It works with any value, including
    values that can be null. I.e. null is a valid value that can be contained inside
    an optional if T is a pointer type (or nullable)
*/
struct Optional(T) {
    import std.traits: isPointer, PointerTarget;
    T[] bag;
    this(U : T)(U u) {
        this.bag = [u];
    }
    bool empty() @property {
        return this.bag.length == 0;
    }
    ref front() @property {
        return this.bag[0];
    }
    void popFront() {
        this.bag = [];
    }

    /// Set to none
    void opAssign(None _) {
        this.bag = [];
    }

    /// Sets value to `t`
    void opAssign(T t) {
        this.bag = [t];
    }

    /// Checks if value == `none`
    bool opEquals(None _) {
        return this.bag.length == 0;
    }
    /**
        Checks if two optionals contain the same value
    */
    bool opEquals(U : T)(Optional!U rhs) {
        return this.bag == rhs.bag;
    }
    /**
        Get pointer to value

        Returns:
            Pointer to value or null if empty
    */
    T* unwrap() {
        return this.empty ? null : &this.bag[0];
    }

    /// Converts value to string `some(T)`` or `no!T``
    string toString() {
        import std.conv: to;
        if (this.bag.length == 0) {
            return "no!" ~ T.stringof;
        }
        return "some!" ~ T.stringof ~ "(" ~ front.to!string ~ ")";
    }

    /**
        True if `rhs` is equal to value contained
    */
    bool opEquals(U : T)(U rhs) {
        return !empty && front == rhs;
    }

    /**
        Dereferences the optional if it is a pointer type

        Returns:
            Another optional that either contains the dereferenced
            value or none
    */
    auto opUnary(string op)() if (op == "*" && isPointer!T) {
        alias P = PointerTarget!T;
        return empty ? no!P : some!P(*front);
    }

    /**
        If the optional is some value it returns an optional of some `value op rhs`
    */
    auto opBinary(string op, U : T)(U rhs) {
        return empty ? no!T : some!T(mixin("front"  ~ op ~ "rhs"));
    }

    /**
        Dispatches all calls to internal value even if there isn't one

        Supports function calls and readonly properties or member variables

        Returns:
            An optional of whatever `fn` returns
    */
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

/// Type constructor for inferring `T`
auto optional(T)(T t) {
    return Optional!T(t);
}

/// Type constructor for inferring `T` with value of none
auto optional(T)() {
    return Optional!T();
}

/// Type constructor for an optional having some value of `T`
auto some(T)(T t) {
    return Optional!T(t);
}

/// Type constructor for an optional having no value of `T`
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
    auto a = some(3);
    assert(a + 3 == some(6));
    auto b = no!int;
    assert(b + 3 == none);
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

/// Checks if T is an optional type
template isOptional(T) {
    static if(is(T U == Optional!U)) {
        enum isOptional = true;
    } else {
        enum isOptional = false;
    }
}

///
unittest {
    assert(isOptional!(Optional!int) == true);
    assert(isOptional!int == false);
    assert(isOptional!(int[]) == false);
}

unittest {
    assert(no!int.toString == "no!int");
    assert(some(3).toString == "some!int(3)");
}
