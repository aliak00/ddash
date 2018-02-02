/**
    Truthy values: so not any of `false`, `null`, `0`, `""`, `none`, and `NaN`.
*/
module utils.istruthy;

///
unittest {
    import optional: some, no;
    assert(true.isTruthy == true);
    assert(1.isTruthy == true);
    assert(0.isTruthy == false);
    assert((new int(3)).isTruthy == true);
    assert(no!int.isTruthy == false);
    assert(some(3).isTruthy == true);
    assert(((int[]).init).isTruthy == false);
    assert([1].isTruthy == true);
    assert(double.nan.isTruthy == false);
    assert(0.0.isTruthy == false);
    assert(1.0.isTruthy == true);
}

import common;

import std.traits: ifTestable, isArray, isPointer, isFloatingPoint;
import optional: isOptional, none;

/// True if `cast(bool)t == true`
bool isTruthy(T)(auto ref T t) if (ifTestable!T && !isArray!T && !isFloatingPoint!T) {
    return cast(bool)t ? true : false;
}

/// True if length is `0`
bool isTruthy(T)(auto ref T t) if (isArray!T) {
    return t.length ? true : false;
}

/// True if value is `none`
bool isTruthy(T)(auto ref T t) if (isOptional!T) {
    return t != none;
}

/// True if not `NaN`
bool isTruthy(T)(auto ref T t) if (isFloatingPoint!T) {
    import std.math: isNaN;
    return t && !t.isNaN;
}

/// Opposite of `isTruthy`
alias isFalsey = from!"std.functional".not!isTruthy;
