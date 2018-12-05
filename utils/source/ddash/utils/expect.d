/**
    An expected result type

    Useful for functions that are expected to return something but could result in an error. The expected type is parameterized over
    two types - the expected one and the `Unexpected`. When you want to assign an unexpected type you must use the provided type constructor
    to make an unexpected assignment.

    An `Expect!(T, U)` type also has a static `expected` and `unexpected` methods to create the given `Expect!(U, V)` with the desired
    state.
*/
module ddash.utils.expect;

///
@nogc unittest {
    Expect!(int, string) even(int i) @nogc {
        if (i % 2 == 0) {
            return typeof(return).expected(i);
        } else {
            return typeof(return).unexpected("not even");
        }
    }

    assert(even(1) == unexpected("not even"));
    assert(even(2) == 2);
}

import std.variant;
import ddash.common;

struct AnyUnexpected {}

/**
    Can be used to compare for any unexpected, i.e. `Expected<U, V> == anyUnexpected`
*/
immutable anyUnexpected = AnyUnexpected();

/**
    Used in the `Expect` type to denote an unexpected value
*/
private struct Unexpected(E) if (!is(E == AnyUnexpected)) {
    E value = E.init;
    alias value this;
}

/**
    Type constructor for an Unexpected value. This must be used when assigning or passing
    an unexpected type to an `Expect!(T, U)`
*/
auto unexpected(E)(E value) {
    return Unexpected!E(value);
}

/**
    The expect type can be used to return values and error codes from functions

    The "expected" value is the success value and the unexpected (which is also typed
    as `Unexpected`) is the failure value.

    The default value is always the init value of the expected case
*/
struct Expect(T, E = Variant) if (!is(E == void)) {
    import sumtype;
    import ddash.lang: Void, isVoid;

    static if (isVoid!T) {
        alias Expected = Void;
    } else {
        alias Expected = T;
    }
    alias Unexpected = .Unexpected!E;

    private SumType!(Expected, Unexpected) data = Expected.init;
    ref get() { return data; }
    alias get this;

    /**
        Constructor takes a Expected and creates a success result. Or takes an E and
        creates an unexpected result
    */
    static if (!isVoid!Expected) {
        this(Expected value) {
            data = value;
        }
    }

    /// Ditto
    this(Unexpected value)  {
        data = value;
    }

    /// Create an `Expect` with an expected value
    static expected(V : Expected)(auto ref V value) {
        return Expect!(Expected, E)(value);
    }

    /// Create an `Expect` with an unexpected value
    static unexpected(V)(auto ref V value) if (is(E == Variant) || is(V : E)) {
        // If E is a variant type than then we allow any V and just store it as a variant
        static if (is(E == Variant) && !is(V == Variant)) {
            return Expect!(Expected, E)(Unexpected(Variant(value)));
        } else {
            return Expect!(Expected, E)(Unexpected(value));
        }
    }

    /// Returns true if the value is expected
    bool isExpected() const {
        return sumtype.match!(
            (const Expected _) => true,
            (const Unexpected _) => false,
        )(this.data);
    }

    /**
        compares a value or an unexpected value. To compare with an unepexted value
        you must used either `Unexpected!E` as the rhs or it's type contructor.

        If you do not care about the value of the unexpected then you can compare
        against `anyUnexpected`
    */
    bool opEquals(Expected rhs) const {
        if (!this.isExpected) return false;
        return sumtype.match!(
            (const Expected lhs) => lhs,
            (const Unexpected _) => Expected.init,
        )(this.data) == rhs;
    }

    /// Ditto
    bool opEquals(Unexpected rhs) const {
        if (this.isExpected) return false;
        return sumtype.match!(
            (const Expected _) => Unexpected.init,
            (const Unexpected lhs) => lhs,
        )(this.data) == rhs;
    }

    /// Ditto
    bool opEquals(AnyUnexpected) const {
        return !this.isExpected;
    }

    /// Calls std.conv.to!string on T or E
    string toString() const {
        import std.conv: to;
        return sumtype.match!(
            (const Expected value) => "Expected(" ~ value.to!string ~ ")",
            (const Unexpected value) => "Unexpected(" ~ value.to!string ~ ")",
        )(this.data);
    }
}

///
unittest {
    Expect!int toInt(string str) {
        alias Result = typeof(return);
        import std.conv: to;
        try {
            return Result.expected(str.to!int);
        } catch (Exception ex) {
            return Result.unexpected(ex.msg);
        }
    }

    assert(toInt("33") == 33);
    assert(toInt("!33") == anyUnexpected);
}

unittest {
    assert(Expect!int.expected(10).toString == "Expected(10)");
    assert(Expect!(int, int).unexpected(11).toString == "Unexpected(11)");
}

/**
    Evaluates to true if `T` is a `Expect` type
*/
template isExpect(T) {
    import std.traits: isInstanceOf;
    enum isExpect = isInstanceOf!(Expect, T);
}

/**
    Pass in 2 handlers, one that handles `Expected` and another that
    handles `Unexpected`
*/
template match(handlers...) {
    auto match(T)(auto ref T expectInstance) if (isExpect!T) {
        static import sumtype;
        return sumtype.match!handlers(expectInstance.data);
    }
}

///
unittest {
    Expect!(int, string) even(int i) @nogc {
        if (i % 2 == 0) {
            return typeof(return).expected(i);
        } else {
            return typeof(return).unexpected("not even");
        }
    }

    import std.meta: AliasSeq;

    alias handlers = AliasSeq!(
        (int n) => n,
        (Unexpected!string str) => -1,
    );

    auto a = even(1).match!handlers;
    auto b = even(2).match!handlers;

    assert(a == -1);
    assert(b == 2);
}

