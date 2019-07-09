module ddash.lang.range;

private:

import std.traits;

public import std.range: popFront, front, empty;
public import ddash.lang.headmutable;

/**
    True if type `T` is an input range.
*/
public template isInputRange(T) {
    enum bool isOk(R) = is(typeof(R.init) == R)
        && is(ReturnType!((R s) => s.empty) == bool)
        && is(typeof((return ref R s) => s.front))
        && !is(ReturnType!((R s) => s.front) == void)
        && is(typeof((R s) => s.popFront));
    static if (isMutable!T) {
        enum isInputRange = isOk!T;
    } else static if (is(HeadMutable!T MT)) {
        enum isInputRange = isOk!MT;
    } else {
        enum isInputRange = false;
    }
}

public template isForwardRange(T) {
    enum bool isForwardRange = isInputRange!T
        && __traits(compiles, {
            T t = T.init;
        });
}

/**
    Checks if a range implements a head-mutable version
*/
public template implementsHeadMutable(Range) if (isInputRange!Range) {
    enum implementsHeadMutable = is(HeadMutable!Range);
}

/**
    Generic type constructor for a range that can be made mutable.
*/
public auto ref mutable(Range)(auto ref Range range) if (implementsHeadMutable!Range) {
    return range.opHeadMutable;
}

public template ResolvedHeadMutable(Range) if (isInputRange!Range) {
    static if (implementsHeadMutable!Range) {
        alias ResolvedHeadMutable = HeadMutable!Range;
    } else {
        alias ResolvedHeadMutable = Range;
    }
}

public auto ref resolveOpHeadMutable(Sequence)(auto ref Sequence sequence) {
    static if (implementsHeadMutable!Sequence) {
        return sequence.opHeadMutable;
    } else {
        return sequence;
    }
}
