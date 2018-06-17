/**
    Truthy values: so not any of `false`, `null`, `0`, `""`, `none`, and `NaN`.
*/
module ddash.utils.istruthy;

///
unittest {
    assert( isTruthy(true));
    assert( isTruthy(1));
    assert(!isTruthy(0));
    assert( isTruthy((new int(3))));
    assert(!isTruthy(((int[]).init)));
    assert( isTruthy([1]));
    assert(!isTruthy(double.nan));
    assert(!isTruthy(0.0));
    assert( isTruthy(1.0));

    class C {}
    C c;
    assert(!isTruthy(c));
    c = new C;
    assert( isTruthy(c));

    struct S {}
    S s;
    assert(!__traits(compiles, isTruthy(s)));
}

import ddash.common;

/**
    Returns true if value is "truthy"

    Params:
        value = any value

    Returns:
        true if truthy
*/
bool isTruthy(T)(auto ref T value) {
    import std.traits: ifTestable, isArray, isPointer, isFloatingPoint;
    import std.range: isInputRange;
    static if (is(T == class) || isPointer!T)
        return value !is null;
    else static if (isArray!T)
        return value.length != 0;
    else static if (isInputRange!T)
        return !value.empty;
    else static if (isFloatingPoint!T)
    {
        import std.math: isNaN;
        return value && !value.isNaN;
    }
    else static if (ifTestable!T)
        return cast(bool)value;
    else
        static assert(
            false,
            "Cannot determine truthyness of type " ~ T.stringof
        );
}

/// Opposite of `isTruthy`
alias isFalsey = from!"std.functional".not!isTruthy;
