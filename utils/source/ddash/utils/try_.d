/**
    Try utiltity that turns an exception-throwing function in to a ranged result
*/
module ddash.utils.try_;

import ddash.common;
import ddash.utils.errors;

///
@("module example")
@safe unittest {
    import std.typecons: tuple;
    import std.algorithm: map, each;
    import ddash.utils.match: match;

    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("NOT EVEN!!!");
        }
        return i;
    }

    static if (FeatureFlag.tryUntil) {
        assert(tryUntil(f(2), f(4), f(6)).front == tuple(2, 4, 6));
    }

    auto result = [1, 2, 3]
        .map!(a => Try!(() => f(a)))
        .map!(r => r
            .match!(
                (int _) => "even",
                (Exception _) => "odd"
            )
        );

    assert(result.equal(["odd", "even", "odd"]));
}

import ddash.common;

/**
    Creates a Try range out of an alias to a function that could throw.

    Calling any range functions on a try range will resolve the delegate and produce
    a `front` range value if the function did not throw.

    You may also call `ddash.utils.match` on the try range.

    See_Also:
        `ddash.functional.try_`

    Since:
        0.8.0
*/
auto Try(alias fun)() {
    auto a = TryImpl!fun();
    a.result = new typeof(*a.result);
    return a;
}

/// Ditto
auto Try(alias fun, Arg)(auto ref Arg arg) {
    return Try!(() => fun(arg));
}

/**
    The implementation of the `Try` that's returned by the type constructor
*/
private struct TryImpl(alias fun) {
    static import ddash.utils.expect;
    import ddash.lang.types: isVoid, Void;
    import ddash.utils.optional;
    import ddash.utils.match;

    private bool _empty;
    public @property bool empty() nothrow {
        resolve;
        return _empty;
    }

    public alias Expect = ddash.utils.expect.Expect!(typeof(fun()), Exception);
    private Optional!Expect* result;

    public bool isSuccess() nothrow {
        auto value = resolve;
        return match!(
            (const Expect.Expected _) => true,
            (const Expect.Unexpected _) => false,
        )(value);
    }

    package(ddash) Expect resolve() nothrow {
        assert(result, "result must never be null");
        if (!result.empty) {
            return result.front;
        }
        Expect value;
        try {
            static if (isVoid!(Expect.Expected)) {
                fun();
                value = Void();
            } else {
                value = fun();
            }
            _empty = false;
        } catch (Exception ex) {
            value = ddash.utils.expect.unexpected(ex);
            _empty = true;
        }
        *result = value;
        return value;
    }

    public @property Expect.Expected front() nothrow {
        auto value = resolve;
        return match!(
            (Expect.Expected t) => t,
            (Expect.Unexpected _) => Expect.Expected.init,
        )(value);
    }

    public size_t length() {
        resolve;
        return !_empty ? 1 : 0;
    }

    public void popFront() nothrow {
        resolve;
        _empty = true;
    }

    /**
        This the the hook implementation for orElseThrow. The makeThrowable predicate
        is given the exception in this Try if there is one, and the result is throw.
        Or or the front of the try is returned
    */
    auto hookOrElseThrow(alias makeThrowable)() {
        auto value = this.resolve;
        alias ExType = typeof(makeThrowable(Expect.Unexpected.init));
        if (!this.empty) {
            return this.front;
        } else {
            Throwable getThrowable() {
                return match!(
                    (Expect.Expected _) => ExType.init,
                    (Expect.Unexpected u) {
                        try {
                            return cast(Throwable)makeThrowable(u.value);
                        } catch (Exception ex) {
                            return cast(Throwable)new OrElseThrowException(ex);
                        }
                    },
                )(value);
            }
            throw getThrowable;
        }
    }
}

/**
    Evaluates to true if `T` is a `Try` type

    Since:
        0.0.8
*/
template isTry(T) {
    import std.traits: isInstanceOf;
    enum isTry = isInstanceOf!(TryImpl, T);
}

@("Should convert Try to Optional")
@safe unittest {
    import ddash.utils.optional;

    int f(int i) {
        if (i % 2 == 1) {
            throw new Exception("NOT EVEN!!!");
        }
        return i;
    }

    assert(Try!(() => f(0)).toOptional == some(0));
    assert(Try!(() => f(1)).toOptional == none);
}

@("should not call lambda more than once when copied around")
@safe unittest {
    int count;
    int func() @safe {
        return count++;
    }

    auto a = Try!func;
    auto b = a;
    auto x = a.front;
    auto y = b.front;
    while (!b.empty) b.popFront;
    assert(x == 0);
    assert(y == 0);
    assert(count == 1);
}

@("orElseThrow should be hooked")
@safe unittest {
    import ddash.utils: orElseThrow;
    import std.exception: assertThrown, collectExceptionMsg;

    int f(int i) {
        if (i % 2 == 0) { throw new Exception("even"); }
        return i;
    }
    static class SomeException : Exception {
        Exception other;
        this(Exception other, string msg) {
            super(msg);
            this.other = other;
        }
    }

    Try!(() => f(2))
        .orElseThrow!((ex) => new SomeException(ex, "got it"))
        .assertThrown!SomeException;

    const message = Try!(() => f(3))
        .orElseThrow!((ex) => new SomeException(ex, "first"))
        .Try!((ret) => f(ret + 1))
        .orElseThrow!((ex) => new SomeException(ex, "second"))
        .collectExceptionMsg;

    assert(message == "second");
}

@("should throw an OrElseException if the exception factory throws")
unittest {
    import std.exception: assertThrown;
    import ddash.utils: orElseThrow;

    int f(int i) {
        if (i % 2 == 0) { throw new Exception("even"); }
        return i;
    }

    Try!(() => f(2))
        .orElseThrow!((ex) { f(2); return ex; } )
        .assertThrown!OrElseThrowException;
}

// The code below requires the fix for bugzilla issue 5710
static if (FeatureFlag.tryUntil) {
    /**
        tryUntil will take a number of lazy expressions and execute them in order
        until they all pass or one of them fails

        Params:
            expressions = a variadic list of expressions

        Returns:
            The result is a `Try` that either has a success value of a `Tuple` of results
            or an `Exception`

        Since:
            0.16.0
    */
    auto tryUntil(T...)(lazy T expressions) {
        import std.meta: staticMap;
        import std.typecons: tuple;
        import ddash.utils.try_: Try;
        template eval(alias expression) {
            auto eval() {
                return expression();
            }
        }
        return Try!(() => staticMap!(eval, expressions).tuple);
    }

    ///
    @("tryUntil example ")
    @safe unittest {
        import std.conv: to;
        import std.algorithm: map, each;
        import std.typecons: Tuple, tuple;
        import ddash.utils.match: match;

        int f(int i) {
            if (i % 2 == 1) {
                throw new Exception("uneven int");
            }
            return i;
        }
        string g(int i) {
            if (i % 2 == 1) {
                throw new Exception("uneven string");
            }
            return i.to!string;
        }

        auto r0 = tryUntil(f(2), g(2)); // both succeed
        assert(r0.front == tuple(2, "2"));

        auto r1 = tryUntil(f(1), g(2)); // first one fails
        auto s1 = r1.match!((_) => "?", ex => ex.msg);
        assert(s1 == "uneven int");

        auto r2 = tryUntil(f(2), g(1)); // second one fails
        auto s2 = r2.match!((_) => "?", ex => ex.msg);
        assert(s2 == "uneven string");
    }

    @("tryUntil should not evaluate remaining expressions if one fails")
    @safe unittest {
        int[] calls;
        int f(int i) {
            calls ~= i;
            if (i % 2 == 1) {
                throw new Exception("boom");
            }
            return i;
        }

        tryUntil(f(0), f(2), f(1), f(4)).array;
        assert(calls == [0, 2, 1]);
    }
}
