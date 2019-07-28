/**
    Gets the value or else something else
*/
module ddash.utils.orelse;

import std.typecons: Nullable;
import ddash.common;
import ddash.utils.errors;

private enum isTypeconsNullable(T) = is(T : Nullable!U, U);
// TODO: replace with bolts.isNullTestable
private enum isNullable(T) = from.bolts.traits.isNullable!T && __traits(compiles, { if (T.init is null) {} });

/**
    Retrieves the value if it is a valid value else it will retrieve the `elseValue`. Instead of
    an `elseValue`, an `elsePred` can be passed to create the value functionally

    Hooks:
        hookOrElse`: if your type has a function called `hookOrElse` and it takes a single predicate,
        then that function will be called with the elsePred instead

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
auto ref orElse(alias elsePred, T)(auto ref T value) {
    // The orer of these checks matter
    static if (from.std.traits.hasMember!(T, "hookOrElse")) {
        // Prioritize the hook
        return value.hookOrElse!elsePred;
    } else static if (isTypeconsNullable!T) {
        // Do this before Range because it could be aliased to a range, in which canse if there's
        // nothing inside, simply calling .empty on it will get Nullables's .get implicitly. BOOM!
        if (value.isNull) {
            return elsePred();
        }
        return value.get;
    } else static if (from.std.range.isInputRange!T) {
        import std.range: ElementType, isInputRange;
        import std.traits: isArray;
        alias ReturnType = typeof(elsePred());
        static if (is(ReturnType : ElementType!T)) {
            if (value.empty) {
                return elsePred();
            } else {
                return value.front;
            }
        } else static if (is(T : ReturnType)) {
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
                "elsePred must return either an element or range or another Range"
            );
        }
    } else static if (isNullable!T) {
        if (value is null) {
            return elsePred();
        }
        return value;
    } else {
        static assert(0,
            "Unable to call orElse on type " ~ T.stringof ~ ". It has to either be an input range,"
            ~ " a null testable type, a Nullable!T or implement hookOrElse(alias elsePred)()"
        );
    }
}

/// Ditto
auto ref orElse(T, U)(auto ref T value, lazy U elseValue) {
    return value.orElse!(elseValue);
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
    static assert(__traits(compiles, { [3].map!(to!string).orElse(""); }));
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

@("orElse should work with custom hook")
unittest {
    static struct EvenType {
        int i;
        int hookOrElse(alias elsePred)() {
            if (i % 2 == 0) {
                return i;
            } else {
                return elsePred();
            }
        }
    }

    assert(EvenType(2).orElse(3) == 2);
    assert(EvenType(1).orElse(3) == 3);
    assert(EvenType(2).orElse!(() => 3) == 2);
    assert(EvenType(1).orElse!(() => 3) == 3);
}

/**
    Same as `orElse` except it throws an error if it can't get the value

    Hooks:
        hookOrElseThrow`: if your type has a function called `hookOrElseThrow(alias makeThrowable)` ,
        then that function will be called and the return value will be returned. It's the hook's job
        to throw if it needs to.

    Params:
        value = the value to resolve
        makeThrowable = the predicate that creates exception `value` cannot be resolved
        throwable = the value to throw if value cannot be resolved

    Returns:
        $(LI If `value` is null testable and not null, then it will return `value`, else throw)
        $(LI If `value` is typecons.Nullable and !isNull, then it will return `value`, else throw)
        $(LI If `value` is a range and !empty,then it will return `value.front`, else throw)

    Since:
        - 0.18.0
*/
auto ref orElseThrow(alias makeThrowable, T)(auto ref T value) {
    // The orer of these checks matter
    static if (from.std.traits.hasMember!(T, "hookOrElseThrow")) {
        // Prioritize the hook
        return value.hookOrElseThrow!makeThrowable;
    } else {
        static if (isTypeconsNullable!T) {
            // Do this before Range because it could be aliased to a range, in which canse if there's
            // nothing inside, simply calling .empty on it will get Nullables's .get implicitly. BOOM!
            if (!value.isNull) {
                return value.get;
            }
        } else static if (from.std.range.isInputRange!T) {
            if (!value.empty) {
                return value.front;
            }
        } else static if (isNullable!T) {
            if (value !is null) {
                return value;
            }
        } else {
            static assert(0,
                "Unable to call orElseThrow on type " ~ T.stringof ~ ". It has to either be an input range,"
                ~ " a null testable type, a Nullable!T, or implement hookOrElseThrow(alias elsePred)()"
            );
        }

        // None of the static branches returned a value, throw!
        throw () {
            try {
                return makeThrowable();
            } catch (Exception ex) {
                throw new OrElseThrowException(ex);
            }
        }();
    }
}

/// Ditto
auto ref orElseThrow(T, U : Throwable)(auto ref T value, lazy U throwable) {
    return value.orElseThrow!(throwable);
}

///
@("orElseThrow example")
unittest {
    import std.exception: assertThrown, assertNotThrown;

    ""
        .orElseThrow(new Exception(""))
        .assertThrown!Exception;

    "yo"
        .orElseThrow(new Exception(""))
        .assertNotThrown!Exception;
}

@("should throw an OrElseException if the exception factory throws")
@safe unittest {
    import std.exception: assertThrown;

    int boo() {throw new Exception(""); }

    ""
        .orElseThrow!(() { boo; return new Exception(""); } )
        .assertThrown!OrElseThrowException;
}

@("Should throw exception if range empty")
unittest {
    import std.exception: assertThrown, assertNotThrown;
    import std.range: iota;

    0.iota(0)
        .orElseThrow(new Exception(""))
        .assertThrown!Exception;

    0.iota(1)
        .orElseThrow(new Exception(""))
        .assertNotThrown!Exception;
}

@("Should throw if nullable isNull")
unittest {
    import std.exception: assertThrown, assertNotThrown;
    import std.typecons: nullable;

    auto a = "foo".nullable;

    a.orElseThrow(new Exception(""))
        .assertNotThrown!Exception;

    a.nullify;

    a.orElseThrow(new Exception(""))
        .assertThrown!Exception;
}

@("orElseThrow should work with custom hook")
unittest {
    import std.exception: assertThrown, assertNotThrown;

    static class MyException : Exception {
        Exception cause;
        this(Exception cause) {
            super(cause.msg);
            this.cause = cause;
        }
    }

    static struct OddType {
        int i;
        int hookOrElseThrow(alias makeThrowable)() {
            if (i % 2 == 0) {
                throw makeThrowable(new Exception("boom"));
            }
            return i;
        }
    }

    OddType(1)
        .orElseThrow!((ex) => new MyException(ex))
        .assertNotThrown!MyException;

    OddType(2)
        .orElseThrow!((ex) => new MyException(ex))
        .assertThrown!MyException;
}
