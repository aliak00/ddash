/**
    Home of the Optional type
*/
module optional;

///
unittest {
    auto a = no!int;
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

    auto c = no!(A*);
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
    import std.range: hasAssignableElements;
    T[] bag;
    this(U : T)(U u) {
        this.bag = [u];
    }
    bool empty() const @property {
        return this.bag.length == 0;
    }
    auto ref front() inout @property {
        return this.bag[0];
    }
    void popFront() {
        this.bag = [];
    }

    static if (hasAssignableElements!(T[]))
    {
        /// Set to none
        void opAssign(None _) {
            this.bag = [];
        }

        /// Sets value to `t`
        void opAssign(T t){
            this.bag = [t];
        }
    }

    /// Checks if value == `none`
    bool opEquals(None _) const {
        return this.bag.length == 0;
    }
    /**
        Checks if two optionals contain the same value
    */
    bool opEquals(U : T)(const auto ref Optional!U rhs) const {
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
    string toString() const {
        import std.conv: to;
        if (this.bag.length == 0) {
            return "no!" ~ T.stringof;
        }
        return "some!" ~ T.stringof ~ "(" ~ front.to!string ~ ")";
    }

    /**
        True if `rhs` is equal to value contained
    */
    bool opEquals(U : T)(const auto ref U rhs) const {
        return !empty && front == rhs;
    }

    /**
        Dereferences the optional if it is a pointer type

        Returns:
            Another optional that either contains the dereferenced
            value or none
    */
    auto opUnary(string op)() inout if (op == "*" && isPointer!T) {
        alias P = PointerTarget!T;
        return empty ? no!P : some!P(*front);
    }

    /**
        If the optional is some value it returns an optional of some `value op rhs`
    */
    auto ref opBinary(string op, U : T)(auto ref U rhs) {
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

///
unittest {
    import std.array;
    import std.algorithm: map;
    assert([1, 2, 3].map!optional.array == [some(1), some(2), some(3)]);
}

/// Type constructor for an optional having some value of `T`
auto some(T)(T t) {
    return Optional!T(t);
}

///
unittest {
    auto a = no!int;
    assert(a == none);
    a = 9;
    assert(a == some(9));
    assert(a != none);
}

/// Type constructor for an optional having no value of `T`
auto no(T)() {
    return Optional!T();
}

///
unittest {
    auto a = no!(int*);
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
    auto n = no!(int);
    auto nc = no!(const int);
    auto ni = no!(immutable int);
    auto o = optional!(int)(3);
    auto oc = optional!(const int)(3);
    auto oi = optional!(immutable int)(3);

    assert(o != n);
    assert(o != nc);
    assert(o != ni);
    assert(oc != n);
    assert(oc != nc);
    assert(oc != ni);
    assert(oi != n);
    assert(oi != nc);
    assert(oi != ni);

    assert(o == oc);
    assert(o == oi);
    assert(oc == oi);

    assert(n == nc);
    assert(n == ni);
    assert(nc == ni);

    o = 4;
    n = 4;
    assert(o == n);

    static assert( is(typeof(n = 3)));
    static assert(!is(typeof(ni = 3)));
    static assert(!is(typeof(nc = 3)));
    static assert( is(typeof(o = 3)));
    static assert(!is(typeof(oi = 3)));
    static assert(!is(typeof(oc = 3)));
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
    const arr = [
        no!int,
        some(3),
        no!int,
        some(7),
    ];
    assert(arr.filter!(a => a != none).array == [some(3), some(7)]);
}

unittest {
    assert(no!int.toString == "no!int");
    assert(some(3).toString == "some!int(3)");
}

/// Checks if T is an optional type
template isOptional(T) {
    static if(is(T U == Optional!U))
    {
        enum isOptional = true;
    }
    else
    {
        enum isOptional = false;
    }
}

///
unittest {
    assert(isOptional!(Optional!int) == true);
    assert(isOptional!int == false);
    assert(isOptional!(int[]) == false);
}

/// Returns the target type of a optional.
alias OptionalTarget(T : Optional!T) = T;

unittest {
    static assert(is(OptionalTarget!(Optional!int) == int));
    static assert(is(OptionalTarget!(Optional!(float*)) == float*));
}
