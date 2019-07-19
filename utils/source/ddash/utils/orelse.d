/**
    Gets the value or else something else
*/
module ddash.utils.orelse;

import std.typecons: Nullable;
import ddash.common;
import ddash.utils.errors;

private enum isTypeconsNullable(T) = is(T : Nullable!U, U);
private enum isNullable(T) = from.bolts.traits.isNullable!T && __traits(compiles, { if (T.init is null) {} });

/**
    Retrieves the value if it is a valid value else it will retrieve the `elseValue`. Instead of
    an `elseValue`, an `elsePred` can be passed to create the value functionally

    Params:
        value = the value to resolve
        elseValue = the value to get if `value` cannot be resolved
        elsePred = the perdicate to call if `value` cannot be resolved

    Returns:
        $(LI If `value` is nullable and null, then it will return the `elseValue`, else `value`)
        $(LI If `value` is typecons.Nullable and isNull, then it will return the `elseValue`, else `value`)
        $(LI If `value` is a range and empty, and `elseValue` is a compatible range,
            then `elseValue` range will be returned, else `value`)
        $(LI If `value` is a range and empty, and `elseValue` is an `ElementType!Range`,
            then `elseValue` will be returned, else `value.front`)

    Since:
        - 0.0.2
*/
auto ref orElse(alias elsePred, Range)(auto ref Range value)
if (from.std.range.isInputRange!Range && !isTypeconsNullable!Range) {
    import std.range: ElementType, isInputRange;
    import std.traits: isArray;
    alias ReturnType = typeof(elsePred());
    static if (is(ReturnType : ElementType!Range)) {
        if (value.empty) {
            return elsePred();
        } else {
            return value.front;
        }
    } else static if (is(Range : ReturnType)) {
        if (value.empty) {
            return elsePred();
        } else {
            return value;
        }
    } else static if (isInputRange!ReturnType) {
        // If it's a range but not implicly convertible
        import std.range: choose, empty;
        return choose(value.empty, elsePred(), value);
    } else {
        static assert(
            0,
            "elsePred must return either an element or Range or another Range"
        );
    }
}

/// Ditto
auto ref orElse(Range, U)(auto ref Range value, lazy U elseValue)
if (from.std.range.isInputRange!Range && !isTypeconsNullable!Range) {
    return value.orElse!elseValue;
}

/// Ditto
auto orElse(alias elsePred, T)(auto ref Nullable!T value) if (is(T : typeof(elsePred()))) {
    if (value.isNull) {
        return elsePred();
    }
    return value.get;
}

/// Ditto
auto orElse(T, U)(auto ref Nullable!T value, lazy U elseValue) if (is(T : U)) {
    return value.orElse!elseValue;
}

/// Ditto
auto orElse(alias elsePred, T)(auto ref T value)
if (!from.std.range.isInputRange!T && isNullable!T && is(T : typeof(elsePred()))) {
    if (value is null) {
        return elsePred();
    }
    return value;
}

/// Ditto
auto orElse(T, U)(auto ref T value, lazy U elseValue)
if (!from.std.range.isInputRange!T && isNullable!T && is(T : U)) {
    return value.orElse!elseValue;
}


///
@("works with ranges, front, and lambdas")
unittest {
    // Get orElse ranges
    assert((int[]).init.orElse([1, 2, 3]).equal([1, 2, 3]));
    assert(([789]).orElse([1, 2, 3]).equal([789]));

    // Get orElse front of ranges
    assert((int[]).init.orElse(3) == 3);
    assert(([789]).orElse(3) == 789);

    // Lambdas
    assert(([789]).orElse!(() => 3) == 789);
    assert(([789]).orElse!(() => [1, 2, 3]).equal([789]));
}

///
@("works with strings")
unittest {
    assert((cast(string)null).orElse("hi") == "hi");
    assert("yo".orElse("hi") == "yo");
    assert("".orElse("x") == "x");
}

@("range to mapped and mapped to range")
unittest {
    import std.algorithm: map;
    auto r0 = [1, 2].orElse([1, 2].map!"a * 2");
    assert(r0.equal([1, 2]));
    auto r1 = (int[]).init.orElse([1, 2].map!"a * 2");
    assert(r1.equal([2, 4]));

    auto r2 = [1, 2].map!"a * 2".orElse([1, 2]);
    assert(r2.equal([2, 4]));
    auto r3 = (int[]).init.map!"a * 2".orElse([1, 2]);
    assert(r3.equal([1, 2]));
}

@("range to front")
unittest {
    assert([1, 2].orElse(3) == 1);
    assert((int[]).init.orElse(3) == 3);
}

@("should work with Nullable")
unittest {
    import std.typecons: nullable;
    auto a = "foo".nullable;
    assert(a.orElse("bar") == "foo");
    a.nullify;
    assert(a.orElse("bar") == "bar");
}

@("should work with mapping ")
unittest {
    import std.algorithm: map;
    import std.conv: to;
    auto a = [3].map!(to!string).orElse("");
}

@("should work with two ranges")
unittest {
    import std.typecons: tuple;
    import std.algorithm: map;
    auto func() {
        return [1, 2, 3].map!(a => tuple(a, a));
    }
    assert(func().orElse(func()).equal(func()));
}

@("should work with class types")
unittest {
    static class C {}

    auto a = new C();
    auto b = new C();
    C c = null;

    assert(a.orElse(b) == a);
    assert(c.orElse(b) == b);
}

/**
    Same as orElse except it throws an error if it can't get the item

    Since:
        - 0.18.0
*/
auto ref orElseThrow(alias makeException, Range)(auto ref Range value)
if (from.std.range.isInputRange!Range && !from.ddash.utils.try_.isTry!Range) {
    if (!value.empty) {
        return value.front;
    }
    throw () {
        try {
            return makeException();
        } catch (Exception ex) {
            throw new OrElseThrowException(ex);
        }
    }();
}

///
@("orElseThrow example")
unittest {
    import std.exception: assertThrown, assertNotThrown;
    "".orElseThrow!(() => new Exception("hello from exception"))
        .assertThrown!Exception;
    "yo".orElseThrow!(() => new Exception("hello from exception"))
        .assertNotThrown!Exception;
}

@("should throw an OrElseException if the exception factory throws")
@safe unittest {
    import std.exception: assertThrown;
    int boo() {throw new Exception("boo"); }
    "".orElseThrow!(() { boo; return new Exception("huh"); } )
        .assertThrown!OrElseThrowException;
}
