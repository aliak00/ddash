module utils.istruthy;

import std.traits: ifTestable, isArray, isPointer, isFloatingPoint;
import optional: isOptional, none;

bool isTruthy(T)(T t) if (ifTestable!T && !isArray!T && !isFloatingPoint!T) {
    return t ? true : false;
}

bool isTruthy(T)(T t) if (isArray!T) {
    return t.length ? true : false;
}

bool isTruthy(T)(T t) if (isOptional!T) {
    return t != none;
}

bool isTruthy(T)(T t) if (isFloatingPoint!T) {
    import std.math: isNaN;
    return !t.isNaN;
}

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
}