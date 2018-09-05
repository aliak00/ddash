/**
    An expected result type
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
immutable anyUnexpected = AnyUnexpected();

/**
    Used in the `Expect` type to denote an unexpected value
*/
struct Unexpected(E) if (!is(E == AnyUnexpected)) {
    E value = E.init;
    alias value this;
}

/// Type constructor for an Unexpected value
auto unexpected(E)(E t) {
    return Unexpected!E(t);
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
        alias InternalType = Void;
    } else {
        alias InternalType = T;
    }

    private SumType!(InternalType, Unexpected!E) data = T.init;
    ref get() { return data; }
    alias get this;

    /**
        Constructor takes a T and creates a success result. Or takes an E and
        creates an unexpected result
    */
    static if (!isVoid!InternalType) {
        this(T value) {
            data = value;
        }
    }

    /// Ditto
    this(Unexpected!E value)  {
        data = value;
    }

    /**
        Pass in 2 handlers, one that handles `T`` and another that
        handles `Unexpected!E`
    */
    auto match(handlers...)() {
        return data.match!handlers;
    }

    /// Create an `Expect` with an expected value
    static expected(V : T)(auto ref V value) {
        return Expect!(T, E)(value);
    }

    /// Create an `Expect` with an unexpected value
    static unexpected(V)(auto ref V value) if (is(E == Variant) || is(V : E)) {
        // If E is a variant type than then we allow any V and just store it as a variant
        static if (is(E == Variant) && !is(V == Variant)) {
            return Expect!(T, E)(Unexpected!E(Variant(value)));
        } else {
            return Expect!(T, E)(Unexpected!E(value));
        }
    }

    /// Returns true if the value is expected
    bool isExpected() const {
        return data.match!(
            (const T _) => true,
            (const Unexpected!E _) => false,
        );
    }

    /**
        compares a value or an unexpected value. To compare with an unepexted value
        you must used either `Unexpected!E` as the rhs or it's type contructor.

        If you do not care about the value of the unexpected then you can compare
        against `anyUnexpected`
    */
    bool opEquals(T rhs) const {
        if (!isExpected) return false;
        return data.match!(
            (const T lhs) => lhs,
            (const Unexpected!E _) => T.init,
        ) == rhs;
    }

    bool opEquals(E)(Unexpected!E rhs) const {
        if (isExpected) return false;
        return data.match!(
            (const T _) => Unexpected!E.init,
            (const Unexpected!E lhs) => lhs,
        ) == rhs;
    }

    bool opEquals(AnyUnexpected) const {
        return !isExpected;
    }

    string toString() {
        import std.conv: to;
        return data.match!(
            (ref T t) => t.to!string,
            (ref Unexpected!E u) => u.to!string,
        );
    }
}

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

