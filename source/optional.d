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
    assert(b.dispatch.f == some(4));

    auto c = no!(A*);
    assert(c.dispatch.f == none);

    c = new A;
    assert(c.dispatch.f == some(4));
}

import common;

struct None {
    // Space is here else ddox test above includes text "struct Node" in its code block
}

/**
    Represents an empty optional value. This is used for convenience
*/
immutable none = None();

private struct OptionalDispatcher(T, from!"std.typecons".Flag!"refOptional" isRef = from!"std.typecons".No.refOptional) {

    import std.traits: hasMember;
    import std.typecons: Yes;

    static if (isRef == Yes.refOptional)
        Optional!T* self;
    else
        Optional!T self;

    alias self this;

    template opDispatch(string name) if (hasMember!(T, name)) {
        import bolts.traits: hasProperty, isManifestAssignable;

        bool empty() {
            import std.traits: isPointer;
            static if (isPointer!T)
                return self.empty || self.front is null;
            else
                return self.empty;
        }

        static if (is(typeof(__traits(getMember, T, name)) == function))
        {
            // non template function
            auto ref opDispatch(Args...)(auto ref Args args) {
                alias C = () => mixin("self.front." ~ name)(args);
                alias R = typeof(C());
                return empty ? OptionalDispatcher!R(no!R) : OptionalDispatcher!R(some(C()));
            }
        }
        else static if (hasProperty!(T, name))
        {
            import bolts.traits: propertySemantics;
            enum property = propertySemantics!(T, name);
            static if (property.canRead)
            {
                @property auto ref opDispatch()() {
                    alias C = () => mixin("self.front." ~ name);
                    alias R = typeof(C());
                    return empty ? OptionalDispatcher!R(no!R) : OptionalDispatcher!R(some(C()));
                }
            }

            static if (property.canWrite)
            {
                @property auto ref opDispatch(V)(auto ref V v) {
                    alias C = () => mixin("self.front." ~ name ~ " = v");
                    alias R = typeof(C());
                    static if (!is(R == void))
                        return empty ? OptionalDispatcher!R(no!R) : OptionalDispatcher!R(some(C()));
                    else
                        if (!empty) {
                            C();
                        }
                }
            }
        }
        else static if (isManifestAssignable!(T, name))
        {
            enum opDispatch = dispatcher(mixin("self.front." ~ name));
        }
        else static if (is(typeof(mixin("self.front." ~ name))))
        {
            auto ref opDispatch()() {
                alias C = () => mixin("self.front." ~ name);
                alias R = typeof(C());
                return empty ? OptionalDispatcher!R(no!R) : OptionalDispatcher!R(some(C()));
            }
        }
        else
        {
            // member template
            template opDispatch(Ts...) {
                enum targs = Ts.length ? "!Ts" : "";
                auto ref opDispatch(Args...)(auto ref Args args) {
                    alias C = () => mixin("self.front." ~ name ~ targs ~ "(args)");
                    alias R = typeof(C());
                    return empty ? OptionalDispatcher!R(no!R) : OptionalDispatcher!R(some(C()));
                }
            }
        }
    }
}

/**
    Optional type. Also known as a Maybe type in some languages.

    This can either contain a value or be empty. It works with any value, including
    values that can be null. I.e. null is a valid value that can be contained inside
    an optional if T is a pointer type (or nullable)
*/
struct Optional(T) {
    import std.traits: isPointer, hasMember;
    import std.range: hasAssignableElements;

    T[] bag;

    this(U)(U u) pure {
        this.bag = [u];
    }
    this(None) pure {
        this.bag = [];
    }
    this(this) pure {
        this.bag = this.bag.dup;
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
        /// Sets value to `t`
        void opAssign(T t) {
            if (this.empty) {
                this.bag = [t];
            } else {
                this.bag[0] = t;
            }
        }
    }

    /// Ditto
    void opAssign(None _) {
        this.bag = [];
    }

    /**
        Checks if two optionals contain the same value, false if either value is `none`
    */
    bool opEquals(U : T)(auto ref Optional!U rhs) const {
        return this.bag == rhs.bag;
    }

    /// Ditto
    bool opEquals(None _) const {
        return this.bag.length == 0;
    }

    /// Ditto
    bool opEquals(U : T)(const auto ref U rhs) const {
        return !empty && front == rhs;
    }

    /**
        If the optional is some value it returns an optional of some `op value`
    */
    auto opUnary(string op)() const if (op != "++" && op != "--") {
        static if (op == "*" && isPointer!T)
        {
            import std.traits: PointerTarget;
            alias P = PointerTarget!T;
            return empty ? no!P : some!P(*front);
        }
        else
        {
            if (empty) {
                return no!T;
            } else {
                auto val = mixin(op ~ "front");
                return some!T(val);
            }
        }
    }

    /// Ditto
    auto opUnary(string op)() if (op == "++" || op == "--") {
        return empty ? no!T : some!T(mixin(op ~ "front"));
    }

    /**
        If the optional is some value it returns an optional of some `value op rhs`
    */
    auto ref opBinary(string op, U : T)(auto ref U rhs) const {
        return empty ? no!T : some!T(mixin("front"  ~ op ~ "rhs"));
    }

    /**
        If the optional is some value it returns an optional of some `rhs op value`
    */
    auto ref opBinaryRight(string op, U : T)(auto ref U rhs) const {
        return empty ? no!T : some!T(mixin("rhs"  ~ op ~ "front"));
    }

    /**
        Calls dot operator on the internal object if not empty

        Returns:
            A type aliased to Optional!T where T's fields take precendence with the dot operator
    */
    auto dispatch() {
        import std.typecons: Yes;
        return OptionalDispatcher!(T, Yes.refOptional)(&this);
    }

    /**
        Get pointer to value

        Returns:
            Pointer to value or null if empty
    */
    const(T)* unwrap() const {
        return this.empty ? null : &this.bag[0];
    }

    /// Converts value to string `"some(T)"` or `"no!T"`
    string toString() {
        import std.conv: to;
        if (this.bag.length == 0) {
            return "no!" ~ T.stringof;
        }
        // TODO: UFCS on front.to does not work here.
        return "some!" ~ T.stringof ~ "(" ~ to!string(front) ~ ")";
    }
}

unittest {
    struct A {
        enum aManifestConstant = "aManifestConstant";
        static immutable aStaticImmutable = "aStaticImmutable";
        auto aField = "aField";
        auto aNonTemplateFunctionArity0() {
            return "aNonTemplateFunctionArity0";
        }
        auto aNonTemplateFunctionArity1(string value) {
            return "aNonTemplateFunctionArity1";
        }
        @property string aProperty() {
            return aField;
        }
        @property void aProperty(string value) {
            aField = value;
        }
        string aTemplateFunctionArity0()() {
            return "aTemplateFunctionArity0";
        }
        string aTemplateFunctionArity1(string T)() {
            return "aTemplateFunctionArity1";
        }
        string dispatch() {
            return "dispatch";
        }
    }

    auto a = some(A());
    auto b = no!A;
    assert(a.dispatch.aField == some("aField"));
    assert(b.dispatch.aField == no!string);
    assert(a.dispatch.aNonTemplateFunctionArity0 == some("aNonTemplateFunctionArity0"));
    assert(b.dispatch.aNonTemplateFunctionArity0 == no!string);
    assert(a.dispatch.aNonTemplateFunctionArity1("") == some("aNonTemplateFunctionArity1"));
    assert(b.dispatch.aNonTemplateFunctionArity1("") == no!string);
    assert(a.dispatch.aProperty == some("aField"));
    assert(b.dispatch.aProperty == no!string);
    a.dispatch.aProperty = "newField";
    b.dispatch.aProperty = "newField";
    assert(a.dispatch.aProperty == some("newField"));
    assert(b.dispatch.aProperty == no!string);
    assert(a.dispatch.aTemplateFunctionArity0 == some("aTemplateFunctionArity0"));
    assert(b.dispatch.aTemplateFunctionArity0 == no!string);
    assert(a.dispatch.aTemplateFunctionArity1!("") == some("aTemplateFunctionArity1"));
    assert(b.dispatch.aTemplateFunctionArity1!("") == no!string);
    assert(a.dispatch.dispatch == some("dispatch"));
    assert(b.dispatch.dispatch == no!string);
}

unittest {
    import std.meta: AliasSeq;
    import std.conv: to;
    import std.algorithm: map;
    foreach (T; AliasSeq!(Optional!int, const Optional!int, immutable Optional!int)) {
        T a = 10;
        T b = none;
        static assert(!__traits(compiles, { int x = a; }));
        static assert(!__traits(compiles, { void func(int n){} func(a); }));
        assert(a == 10);
        assert(b == none);
        assert(a != 20);
        assert(a != none);
        assert(+a == some(10));
        assert(-b == none);
        assert(-a == some(-10));
        assert(+b == none);
        assert(-b == none);
        assert(a + 10 == some(20));
        assert(b + 10 == none);
        assert(a - 5 == some(5));
        assert(b - 5 == none);
        assert(a * 20 == some(200));
        assert(b * 20 == none);
        assert(a / 2 == some(5));
        assert(b / 2 == none);
        assert(10 + a == some(20));
        assert(10 + b == none);
        assert(15 - a == some(5));
        assert(15 - b == none);
        assert(20 * a == some(200));
        assert(20 * b == none);
        assert(50 / a == some(5));
        assert(50 / b == none);
        static if (is(T == Optional!int))  // mutable
        {
            assert(++a == some(11));
            assert(a++ == some(11));
            assert(a == some(12));
            assert(--a == some(11));
            assert(a-- == some(11));
            assert(a == some(10));
            a = a;
            assert(a == some(10));
            a = 20;
            assert(a == some(20));
        }
    }
}

unittest {
    import std.algorithm: map;
    import std.conv: to;
    auto a = some(10);
    auto b = no!int;
    assert(a.map!(to!double).equal([10.0]));
    assert(b.map!(to!double).empty);
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

    import std.algorithm: map;
    assert([1, 2, 3].map!some.array == [some(1), some(2), some(3)]);
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

/// Checks if T is an optional type
template isOptional(T) {
    static if (is(T U == Optional!U))
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

///
unittest {
    static assert(is(OptionalTarget!(Optional!int) == int));
    static assert(is(OptionalTarget!(Optional!(float*)) == float*));
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
    auto o = some!(int)(3);
    auto oc = some!(const int)(3);
    auto oi = some!(immutable int)(3);

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

    assert(a.dispatch.f() == some(7));
    assert(b.dispatch.f() == no!int);
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

    assert(a.dispatch.b.f == some(8));
    assert(a.dispatch.b.m == some(3));

    assert(b.dispatch.b.f == no!int);
    assert(b.dispatch.b.m == no!int);
}

unittest {
    static assert(!__traits(compiles, some(3).max));
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
    static class A {
        override string toString() { return "A"; }
    }
    Object a = new A;
    assert(some(cast(A)a).toString == "some!A(A)");
}

unittest {
    static import std.uni;
    import std.range: only;
    import std.algorithm: joiner, map;

    static maybeValues = [no!string, some("hello"), some("world")];
    assert(maybeValues.joiner.map!(std.uni.toUpper).joiner(" ").equal("HELLO WORLD"));
}

unittest {
    import std.algorithm.iteration : each, joiner;
    static maybeValues = [some("hello"), some("world"), no!string];
    uint count = 0;
    foreach (value; maybeValues.joiner) ++count;
    assert(count == 2);
    maybeValues.joiner.each!(value => ++count);
    assert(count == 4);
}

unittest {
    Optional!(const int) opt = Optional!(const int)(42);
    static assert(!__traits(compiles, opt = some(24)));
    assert(!opt.empty);
    assert(opt.front == 42);
    opt = none;
    assert(opt.empty);
}
